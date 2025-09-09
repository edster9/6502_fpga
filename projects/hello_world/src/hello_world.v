// Hello World Verilog Project
// A simple LED blinker to learn Verilog basics

module hello_world (
    input wire clk,          // 27MHz clock from Tang Nano 9K/20K
    output wire led_r,       // Red LED
    output wire led_g,       // Green LED
    output wire led_b        // Blue LED
);

    // This is a simple binary counter
    // Each LED represents a bit of the counter
    
    // Counter register - 27 bits for much slower blinking
    reg [26:0] counter;
    
    // This is the main logic block
    // It runs on every rising edge of the clock
    always @(posedge clk) begin
        counter <= counter + 1;  // Increment counter every clock cycle
    end
    
    // Connect LEDs to different counter bits for much slower blinking
    // Higher bits change slower, so we get different blink rates
    assign led_r = counter[26];    // Bit 26: ~0.2Hz (5 second period)
    assign led_g = counter[25];    // Bit 25: ~0.4Hz (2.5 second period)  
    assign led_b = counter[24];    // Bit 24: ~0.8Hz (1.25 second period)
    
    /* 
    Learning Notes:
    
    1. MODULES: Everything in Verilog is a module (like a function in other languages)
    2. INPUTS/OUTPUTS: Define the interface to your module
    3. WIRE vs REG: 
       - wire: connects things together (like actual wires)
       - reg: stores values (like variables)
    4. ALWAYS BLOCKS: Code that runs when something happens (@posedge clk = on clock edge)
    5. ASSIGN: Continuous assignment (always active, like gates)
    
    Math: 27MHz clock, counter[26] = 27MHz / 2^26 = 27MHz / 67M = ~0.2Hz blink
    
    This is your first FPGA program! The LEDs will blink at different rates:
    - Red: Slowest (~0.2Hz - 5 second period) 
    - Green: Medium (~0.4Hz - 2.5 second period) 
    - Blue: Fastest (~0.8Hz - 1.25 second period)
    */

endmodule
