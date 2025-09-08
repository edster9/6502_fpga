// Testbench for Hello World project
// This simulates our design so we can see if it works before putting it on the FPGA

`timescale 1ns / 1ps

module hello_world_tb();

    // Declare signals for our testbench
    reg clk;                    // Clock signal (we control this)
    wire led_r, led_g, led_b;   // LED outputs (our module controls these)
    
    // Create our "hello_world" module - this is called "instantiation"
    hello_world uut (   // uut = "Unit Under Test"
        .clk(clk),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)
    );
    
    // Generate a clock signal
    // Real Tang Nano has 24MHz, but for simulation we use faster clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Toggle every 10ns = 50MHz clock
    end
    
    // Main simulation control
    initial begin
        // Save waveform data for viewing
        $dumpfile("build/hello-world.vcd");
        $dumpvars(0, hello_world_tb);
        
        // Print header
        $display("=== Hello World Verilog Simulation ===");
        $display("Time(ns) | LEDs");
        $display("---------|-----");
        
        // Run simulation for enough time to see LED changes
        #2000000;  // 2 million ns = 2ms
        
        $display("=== Simulation Complete! ===");
        $display("Check build/hello_world.vcd with GTKWave to see waveforms");
        $finish;
    end
    
    // Monitor LED changes during simulation
    always @(led_r or led_g or led_b) begin
        $display("%8t | R=%b G=%b B=%b", $time, led_r, led_g, led_b);
    end
    
    /*
    Learning Notes:
    
    1. TESTBENCH: A special module that tests your design
    2. `timescale: Sets the time units for simulation
    3. REG vs WIRE in testbench:
       - reg: signals you control (like clk)
       - wire: signals from the module you're testing
    4. INITIAL blocks: Run once at the start of simulation
    5. $display: Print text (like printf in C)
    6. $dumpfile/$dumpvars: Save simulation data for waveform viewer
    7. #delay: Wait for a certain time in simulation
    */

endmodule
