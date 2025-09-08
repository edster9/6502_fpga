// Simple CPU Testbench
// Testbench for the simple_cpu module

`timescale 1ns / 1ps

module simple_cpu_tb;

    // Clock and reset signals
    reg clk;
    reg reset;
    
    // Instantiate the Unit Under Test (UUT)
    simple_cpu uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock generation - 50MHz (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize Inputs
        reset = 1;
        
        // Wait for global reset
        #100;
        
        // Release reset
        reset = 0;
        
        // Run simulation for some time
        #1000;
        
        // Add more test cases here
        
        // Finish simulation
        $dumpflush;
        $finish;
    end
    
    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("simple_cpu.vcd");
        $dumpvars(0, simple_cpu_tb);
    end
    
    // Monitor signals
    initial begin
        $monitor("Time: %0t | Reset: %b | Clock: %b", $time, reset, clk);
    end

endmodule
