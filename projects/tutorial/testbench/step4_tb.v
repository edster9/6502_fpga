`timescale 1ns / 1ps

module step4_tb;

    // Inputs
    reg clk;
    reg button;
    
    // Outputs
    wire led_r, led_g, led_b;
    
    // Instantiate the Unit Under Test (UUT)
    step4 uut (
        .clk(clk),
        .button(button),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock
    end
    
    // Test stimulus
    initial begin
        // Initialize Inputs
        button = 0;
        
        // Wait a bit
        #1000000; // 1ms
        
        // Test button press
        button = 1;
        #50000;   // 50us (simulate bounce)
        button = 0;
        #30000;   // 30us
        button = 1;
        #100000;  // 100us stable press
        button = 0;
        
        // Wait a bit
        #2000000; // 2ms
        
        // Test another button press
        button = 1;
        #40000;   // 40us (simulate bounce)
        button = 0;
        #20000;   // 20us
        button = 1;
        #150000;  // 150us stable press
        button = 0;
        
        // Wait to see the effect
        #5000000; // 5ms
        
        // End simulation
        $finish;
    end
    
    // Generate VCD file for GTKWave
    initial begin
        $dumpfile("build/tutorial_step4.vcd");
        $dumpvars(0, step4_tb);
    end
    
    // Monitor changes
    initial begin
        $monitor("Time: %t, Button: %b, RGB: %b%b%b", 
                $time, button, led_r, led_g, led_b);
    end
    
endmodule
