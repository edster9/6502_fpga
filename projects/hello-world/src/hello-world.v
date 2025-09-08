// Hello World Verilog Project
// A simple LED counter to learn Verilog basics

module hello_world (
    input wire clk,          // 27MHz clock from Tang Nano 9K/20K
    output wire led_r,       // Red LED
    output wire led_g,       // Green LED
    output wire led_b        // Blue LED
);

    // This is a simple binary counter
    // Each LED represents a bit of the counter
    
    // Counter register - 24 bits is enough for visible blinking
    reg [23:0] counter;
    
    // This is the main logic block
    // It runs on every rising edge of the clock
    always @(posedge clk) begin
        counter <= counter + 1;  // Increment counter every clock cycle
    end
    
    // Connect LEDs to different counter bits
    // Higher bits change slower, so we get different blink rates
    assign led_r = counter[21];    // Bit 21: slowest blink (~1.3Hz at 27MHz)
    assign led_g = counter[20];    // Bit 20: medium blink (~2.6Hz at 27MHz)  
    assign led_b = counter[19];    // Bit 19: fastest blink (~5.1Hz at 27MHz)
    
    /* 
    Learning Notes:
    
    1. MODULES: Everything in Verilog is a module (like a function in other languages)
    2. INPUTS/OUTPUTS: Define the interface to your module
    3. WIRE vs REG: 
       - wire: connects things together (like actual wires)
       - reg: stores values (like variables)
    4. ALWAYS BLOCKS: Code that runs when something happens (@posedge clk = on clock edge)
    5. ASSIGN: Continuous assignment (always active, like gates)
    
    Math: 27MHz clock, counter[21] = 27MHz / 2^21 = ~12.9Hz / 10 = ~1.3Hz blink
    */

endmodule
