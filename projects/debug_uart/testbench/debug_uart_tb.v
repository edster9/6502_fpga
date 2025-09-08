// Debug UART Testbench
// Tests the UART debug output functionality

`timescale 1ns/1ps

module debug_uart_tb;

    // Testbench signals
    reg clk;
    wire led_r, led_g, led_b;
    wire uart_tx;
    
    // Instantiate the debug_uart module
    debug_uart uut (
        .clk(clk),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b),
        .uart_tx(uart_tx)
    );
    
    // Clock generation (27MHz = ~37ns period)
    initial begin
        clk = 0;
        forever #18.5 clk = ~clk;  // 27MHz clock
    end
    
    // UART bit monitoring
    reg [7:0] uart_byte;
    reg [3:0] bit_count;
    reg receiving;
    reg [31:0] uart_timer;
    localparam UART_PERIOD = 8680;  // 115200 baud at 27MHz
    
    // UART receiver for debugging
    initial begin
        receiving = 0;
        bit_count = 0;
        uart_byte = 0;
        uart_timer = 0;
    end
    
    // Simple UART monitor
    always @(negedge uart_tx) begin
        if (!receiving) begin
            receiving = 1;
            bit_count = 0;
            uart_timer = 0;
            #(UART_PERIOD * 1.5); // Wait 1.5 bit times to middle of first data bit
        end
    end
    
    always @(posedge clk) begin
        if (receiving) begin
            uart_timer <= uart_timer + 1;
            if (uart_timer >= UART_PERIOD) begin
                uart_timer <= 0;
                if (bit_count < 8) begin
                    uart_byte[bit_count] <= uart_tx;
                    bit_count <= bit_count + 1;
                end else begin
                    // Stop bit received
                    receiving <= 0;
                    if (uart_byte >= 32 && uart_byte <= 126) begin
                        $write("%c", uart_byte);  // Print ASCII character
                    end else if (uart_byte == 13) begin
                        $write("\n");  // Carriage return
                    end else if (uart_byte == 10) begin
                        // Line feed - already handled by \n
                    end else begin
                        $write("[0x%02X]", uart_byte);  // Non-printable
                    end
                end
            end
        end
    end
    
    // Test sequence
    initial begin
        // Save waveform data for viewing
        $dumpfile("build/debug_uart.vcd");
        $dumpvars(0, debug_uart_tb);
        
        // Print header
        $display("=== Debug UART Verilog Simulation ===");
        $display("Time(ns) | LEDs | UART Output");
        $display("---------|------|------------");
        $display("UART Messages will appear below:");
        
        // Run simulation for enough time to see debug messages
        #200000000;  // 200 million ns = 200ms (should see multiple debug messages)
        
        $display("");
        $display("=== Simulation Complete! ===");
        $display("Check build/debug_uart.vcd with GTKWave to see waveforms");
        $finish;
    end
    
    // Monitor LED changes during simulation
    always @(led_r or led_g or led_b) begin
        $display("%8t | R=%b G=%b B=%b |", $time, led_r, led_g, led_b);
    end
    
    /*
    Learning Notes:
    
    1. UART MONITORING: Testbench includes basic UART receiver
    2. BAUD RATE: Must match the design (115200 baud)
    3. ASCII OUTPUT: Converts received bytes to readable characters
    4. TIMING: Debug messages sent every ~134 million clock cycles
    5. WAVEFORMS: Use GTKWave to see detailed signal behavior
    
    Expected behavior:
    - LEDs blink at different rates
    - UART sends "Hello! Counter: 0xXXXX" messages
    - Messages appear every ~5 seconds in real time
    - Counter values increment between messages
    */

endmodule
