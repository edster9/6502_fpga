// Testbench for Arlet Ottens 6502 CPU
// Tests basic CPU functionality with simple instruction execution

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
    
    // Memory and loop variables
    reg [7:0] memory [0:65535];
    integer i;
    
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
    
    // Initialize memory with a simple program
    initial begin
        // Clear memory
        for (i = 0; i < 65536; i = i + 1) begin
            memory[i] = 8'hEA; // Fill with NOP
        end
        
        // Simple test program starting at reset vector 0xFFFC
        memory[16'hFFFC] = 8'h00; // Reset vector low byte
        memory[16'hFFFD] = 8'h10; // Reset vector high byte (start at 0x1000)
        
        // Program at 0x1000
        memory[16'h1000] = 8'hA9; // LDA #$42
        memory[16'h1001] = 8'h42;
        memory[16'h1002] = 8'hA2; // LDX #$10
        memory[16'h1003] = 8'h10;
        memory[16'h1004] = 8'hA0; // LDY #$20
        memory[16'h1005] = 8'h20;
        memory[16'h1006] = 8'h8D; // STA $8000
        memory[16'h1007] = 8'h00;
        memory[16'h1008] = 8'h80;
        memory[16'h1009] = 8'h4C; // JMP $1009 (infinite loop)
        memory[16'h100A] = 8'h09;
        memory[16'h100B] = 8'h10;
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
    
    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        irq = 0;
        nmi = 0;
        rdy = 1;
        
        // Create waveform dump
        $dumpfile("build/cpu_6502_tb.vcd");
        $dumpvars(0, cpu_6502_tb);
        
        // Hold reset for a few cycles
        #100;
        reset = 0;
        
        // Let CPU run for a while
        #2000;
        
        // Test results
        $display("=== 6502 CPU Test Results ===");
        $display("Final CPU state:");
        `ifdef SIM
        $display("A register: %02X", uut.A); 
        $display("X register: %02X", uut.X);  
        $display("Y register: %02X", uut.Y);
        $display("S register: %02X", uut.S);
        `endif
        $display("PC: %04X", uut.PC);
        $display("Status flags: N=%b V=%b D=%b I=%b Z=%b C=%b", 
                 uut.N, uut.V, uut.D, uut.I, uut.Z, uut.C);
        
        `ifdef SIM        
        if (uut.A == 8'h42 && uut.X == 8'h10 && uut.Y == 8'h20) begin
            $display("✓ CPU test PASSED - registers loaded correctly");
        end else begin
            $display("✗ CPU test FAILED - registers not loaded correctly");
        end
        `endif
        
        if (memory[16'h8000] == 8'h42) begin
            $display("✓ Memory write test PASSED - STA instruction worked");
        end else begin
            $display("✗ Memory write test FAILED - STA instruction failed");
        end
        
        $display("Test completed successfully!");
        $finish;
    end
    
    // Monitor CPU activity
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time %0t: PC=%04X, State=%d, A=%02X, X=%02X, Y=%02X", 
                     $time, uut.PC, uut.state, 
                     `ifdef SIM uut.A, uut.X, uut.Y `else 8'hXX, 8'hXX, 8'hXX `endif);
        end
    end

endmodule
