// Comprehensive testbench for Arlet Ottens 6502 CPU
// Tests CPU functionality with real 6502 assembly program

`timescale 1ns / 1ps

module cpu_6502_tb;

    // Testbench signals
    reg clk;
    reg reset;
    wire [15:0] addr;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire we;
    reg irq;
    reg nmi;
    reg rdy;
    
    // Memory and program variables
    reg [7:0] memory [0:65535];
    integer i;
    integer cycle_count;
    reg test_passed;
    
    // Instantiate CPU
    cpu uut (
        .clk(clk),
        .reset(reset),
        .AB(addr),
        .DI(data_in),
        .DO(data_out),
        .WE(we),
        .IRQ(irq),
        .NMI(nmi),
        .RDY(rdy)
    );
    
    // Load test program into memory
    initial begin
        // Clear memory with NOPs
        for (i = 0; i < 65536; i = i + 1) begin
            memory[i] = 8'hEA; // NOP instruction
        end
        
        // Set reset vector to start at $C000
        memory[16'hFFFC] = 8'h00; // Reset vector low byte
        memory[16'hFFFD] = 8'hC0; // Reset vector high byte
        
        // Test program at $C000 - comprehensive 6502 instruction test
        i = 16'hC000;
        
        // Test 1: Load immediate values
        memory[i] = 8'hA9; i = i + 1; // LDA #$42
        memory[i] = 8'h42; i = i + 1;
        memory[i] = 8'hA2; i = i + 1; // LDX #$33  
        memory[i] = 8'h33; i = i + 1;
        memory[i] = 8'hA0; i = i + 1; // LDY #$24
        memory[i] = 8'h24; i = i + 1;
        
        // Test 2: Store to memory
        memory[i] = 8'h8D; i = i + 1; // STA $8000
        memory[i] = 8'h00; i = i + 1;
        memory[i] = 8'h80; i = i + 1;
        memory[i] = 8'h8E; i = i + 1; // STX $8001
        memory[i] = 8'h01; i = i + 1;
        memory[i] = 8'h80; i = i + 1;
        memory[i] = 8'h8C; i = i + 1; // STY $8002
        memory[i] = 8'h02; i = i + 1;
        memory[i] = 8'h80; i = i + 1;
        
        // Test 3: Load from memory
        memory[i] = 8'hAD; i = i + 1; // LDA $8001 (should load X value)
        memory[i] = 8'h01; i = i + 1;
        memory[i] = 8'h80; i = i + 1;
        
        // Test 4: Simple arithmetic
        memory[i] = 8'h18; i = i + 1; // CLC (clear carry)
        memory[i] = 8'h69; i = i + 1; // ADC #$10
        memory[i] = 8'h10; i = i + 1;
        memory[i] = 8'h8D; i = i + 1; // STA $8003 (store result)
        memory[i] = 8'h03; i = i + 1;
        memory[i] = 8'h80; i = i + 1;
        
        // Test 5: Increment/Decrement
        memory[i] = 8'hE8; i = i + 1; // INX
        memory[i] = 8'hC8; i = i + 1; // INY
        memory[i] = 8'hCA; i = i + 1; // DEX
        
        // Test 6: Set test completion flag
        memory[i] = 8'hA9; i = i + 1; // LDA #$FF
        memory[i] = 8'hFF; i = i + 1;
        memory[i] = 8'h8D; i = i + 1; // STA $8004 (test completion marker)
        memory[i] = 8'h04; i = i + 1;
        memory[i] = 8'h80; i = i + 1;
        
        // Infinite loop
        memory[i] = 8'h4C; i = i + 1; // JMP to current location
        memory[i] = (i & 8'hFF); i = i + 1;
        memory[i] = ((i-1) >> 8) & 8'hFF;
        
        $display("Test program loaded. Starting at $C000, reset vector points to $C000");
    end
    
    // Memory read logic
    always @(posedge clk) begin
        data_in <= memory[addr];
    end
    
    // Memory write logic  
    always @(posedge clk) begin
        if (we) begin
            memory[addr] <= data_out;
            $display("Memory write: addr=%04X, data=%02X", addr, data_out);
        end
    end
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock
    end
    
    // Test sequence and verification
    initial begin
        // Initialize signals
        reset = 1;
        irq = 0;
        nmi = 0;
        rdy = 1;
        cycle_count = 0;
        test_passed = 0;
        
        // Create waveform dump
        $dumpfile("build/cpu_6502_tb.vcd");
        $dumpvars(0, cpu_6502_tb);
        
        $display("=== Starting 6502 CPU Comprehensive Test ===");
        
        // Hold reset for several cycles
        #200;
        reset = 0;
        $display("Reset released, CPU starting...");
        
        // Run test program and monitor for completion
        while (cycle_count < 1000 && !test_passed) begin
            #20; // Wait one clock cycle
            cycle_count = cycle_count + 1;
            
            // Check if test completion marker was written
            if (memory[16'h8004] == 8'hFF) begin
                test_passed = 1;
                $display("Test completion detected at cycle %d", cycle_count);
            end
        end
        
        if (!test_passed) begin
            $display("WARNING: Test did not complete within 1000 cycles");
        end
        
        // Additional cycles to see final state
        #200;
        
        // Verify test results
        $display("=== 6502 CPU Test Results ===");
        $display("Test completed after %d cycles", cycle_count);
        $display("");
        $display("Memory test results:");
        $display("  $8000 (A reg): $%02X (expected: $42)", memory[16'h8000]);
        $display("  $8001 (X reg): $%02X (expected: $33)", memory[16'h8001]);  
        $display("  $8002 (Y reg): $%02X (expected: $24)", memory[16'h8002]);
        $display("  $8003 (A+$10): $%02X (expected: $43)", memory[16'h8003]);
        $display("  $8004 (marker): $%02X (expected: $FF)", memory[16'h8004]);
        $display("");
        
        // Verify expected results
        if (memory[16'h8000] == 8'h42 && 
            memory[16'h8001] == 8'h33 && 
            memory[16'h8002] == 8'h24 && 
            memory[16'h8003] == 8'h43 && 
            memory[16'h8004] == 8'hFF) begin
            $display("[PASS] ALL TESTS PASSED! 6502 CPU is working correctly");
        end else begin
            $display("[FAIL] Some tests FAILED. Check memory contents above.");
        end
        
        $display("");
        $display("Final CPU state:");
        $display("  PC: $%04X", uut.PC);
        $display("  Status: N=%b V=%b D=%b I=%b Z=%b C=%b", 
                 uut.N, uut.V, uut.D, uut.I, uut.Z, uut.C);
        
        $finish;
    end
    
    // Monitor CPU activity (less verbose)
    always @(posedge clk) begin
        if (!reset && cycle_count < 50) begin
            $display("Cycle %3d: PC=$%04X, Instruction=$%02X", 
                     cycle_count, uut.PC, data_in);
        end
    end

endmodule
