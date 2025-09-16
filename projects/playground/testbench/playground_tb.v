// Playground Testbench
// Simple testbench for experimenting and learning

`timescale 1ns / 1ps

module playground_tb;

    // Testbench signals
    reg clk;
    reg reset;
    wire [5:0] led;
    wire test_pin;
    
    // Instantiate the playground module
    playground uut (
        .clk(clk),
        .reset(reset),
        .led(led),
        .test_pin(test_pin)
    );
    
    // Clock generation - 27MHz (37ns period)
    always #18.5 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        
        // Apply reset
        #100;
        reset = 1;
        
        // Run simulation for a while
        #1000000;  // 1ms simulation time
        
        // Display some results
        $display("LED pattern at end: %b", led);
        $display("Test pin state: %b", test_pin);
        
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("Time: %t, Reset: %b, LED: %b, Test: %b", 
                 $time, reset, led, test_pin);
    end

endmodule