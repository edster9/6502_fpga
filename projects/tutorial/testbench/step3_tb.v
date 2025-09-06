`timescale 1ns / 1ps

module step3_tb;

    // Inputs
    reg clk;
    reg reset_n;
    
    // Outputs
    wire led_r, led_g, led_b;
    
    // Instantiate the Unit Under Test (UUT)
    step3 uut (
        .clk(clk),
        .reset_n(reset_n),
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
        reset_n = 0;
        
        // Wait for global reset
        #100;
        
        // Release reset
        reset_n = 1;
        
        // Let the simulation run for enough time to see PWM breathing effect
        #10000000; // 10ms should be enough to see breathing pattern
        
        // End simulation
        $finish;
    end
    
    // Generate VCD file for GTKWave
    initial begin
        $dumpfile("build/tutorial_step3.vcd");
        $dumpvars(0, step3_tb);
    end
    
    // Monitor changes (sample every 100 cycles to avoid too much output)
    integer monitor_counter = 0;
    always @(posedge clk) begin
        monitor_counter = monitor_counter + 1;
        if (monitor_counter % 1000 == 0) begin
            $display("Time: %t, Reset: %b, RGB: %b%b%b", $time, reset_n, led_r, led_g, led_b);
        end
    end
    
endmodule
