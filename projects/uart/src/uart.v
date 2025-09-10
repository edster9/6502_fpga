// UART Verilog Project
// LED counter with UART debug output for learning hardware debugging

module uart (
    input wire clk,          // 27MHz clock from Tang Nano 9K/20K
    output wire led_r,       // Red LED
    output wire led_g,       // Green LED
    output wire led_b,       // Blue LED
    output wire uart_tx      // UART TX for debug output
);

    // This is a simple binary counter
    // Each LED represents a bit of the counter
    
    // Counter register - 24 bits is enough for visible blinking
    reg [23:0] counter;
    
    // Debug output timing - VERY FAST for original working version
    reg [18:0] debug_counter;  // Much smaller counter for faster output
    wire debug_trigger = (debug_counter == 19'd524287); // Trigger when counter reaches 2^19-1
    
    // This is the main logic block
    // It runs on every rising edge of the clock
    always @(posedge clk) begin
        counter <= counter + 1;       // Increment counter every clock cycle
        
        // Debug message timing with reset
        if (debug_counter == 19'd524287) begin
            debug_counter <= 19'd0;   // Reset to restart the timing cycle
        end else begin
            debug_counter <= debug_counter + 1;  // Keep counting
        end
    end
    
    // Connect LEDs to different counter bits
    // Higher bits change slower, so we get different blink rates
    assign led_r = counter[21];    // Bit 21: slowest blink (~1.3Hz at 27MHz)
    assign led_g = counter[20];    // Bit 20: medium blink (~2.6Hz at 27MHz)  
    assign led_b = counter[19];    // Bit 19: fastest blink (~5.1Hz at 27MHz)
    
    // UART Debug Module Instance - original working version
    uart_debug debug_uart_inst (
        .clk(clk),
        .reset(1'b0),                    // No reset for this simple example
        .uart_tx(uart_tx),               // Connect to UART TX pin
        .debug_trigger(debug_trigger)    // Send message very frequently
    );
    
    /* 
    Learning Notes:
    
    1. MODULES: Everything in Verilog is a module (like a function in other languages)
    2. INPUTS/OUTPUTS: Define the interface to your module
    3. WIRE vs REG: 
       - wire: connects things together (like actual wires)
       - reg: stores values (like variables)
    4. ALWAYS BLOCKS: Code that runs when something happens (@posedge clk = on clock edge)
    5. ASSIGN: Continuous assignment (always active, like gates)
    6. MODULE INSTANCES: Using other modules inside your design (like calling functions)
    
    Math: 27MHz clock, counter[21] = 27MHz / 2^21 = ~12.9Hz / 10 = ~1.3Hz blink
    
    NEW: UART Debug Output!
    - Connect a USB-to-serial adapter to pin 17 (TX)
    - Open a terminal at 115200 baud
    - See real-time counter values every ~5 seconds
    - Learn how your FPGA is running in real-time!
    */

endmodule

// Simple UART Debug Module - Minimal and Robust Version
module uart_debug (
    input wire clk,              // 27MHz system clock
    input wire reset,            // Reset signal
    output reg uart_tx,          // UART TX pin
    input wire debug_trigger     // When to send debug message
);

    // UART parameters for 115200 baud at 27MHz
    parameter BAUD_DIVISOR = 234; // 27,000,000 / 115200 ≈ 234
    
    // Simple state machine
    reg [2:0] state;
    reg [7:0] baud_counter;
    reg [3:0] bit_counter;
    reg [3:0] char_counter;
    reg [7:0] current_char;
    reg debug_trigger_prev;
    
    // States
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3, NEXT = 4;
    
    // Simple message: "Hello\r\n"
    reg [7:0] message [0:6];
    initial begin
        message[0] = "H";
        message[1] = "e";
        message[2] = "l";
        message[3] = "l";
        message[4] = "o";
        message[5] = 8'h0D; // \r
        message[6] = 8'h0A; // \n
    end
    
    // Main UART logic
    always @(posedge clk) begin
        if (reset) begin
            uart_tx <= 1'b1;
            state <= IDLE;
            baud_counter <= 0;
            bit_counter <= 0;
            char_counter <= 0;
            debug_trigger_prev <= 0;
        end else begin
            debug_trigger_prev <= debug_trigger;
            
            case (state)
                IDLE: begin
                    uart_tx <= 1'b1;
                    baud_counter <= 0;
                    if (debug_trigger && !debug_trigger_prev) begin
                        char_counter <= 0;
                        current_char <= message[0];
                        state <= START;
                    end
                end
                
                START: begin
                    if (baud_counter >= BAUD_DIVISOR - 1) begin
                        uart_tx <= 1'b0; // Start bit
                        state <= DATA;
                        bit_counter <= 0;
                        baud_counter <= 0;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                DATA: begin
                    if (baud_counter >= BAUD_DIVISOR - 1) begin
                        uart_tx <= current_char[bit_counter]; // LSB first
                        baud_counter <= 0;
                        if (bit_counter >= 7) begin
                            state <= STOP;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                STOP: begin
                    if (baud_counter >= BAUD_DIVISOR - 1) begin
                        uart_tx <= 1'b1; // Stop bit
                        state <= NEXT;
                        baud_counter <= 0;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                NEXT: begin
                    if (char_counter >= 6) begin
                        state <= IDLE;
                    end else begin
                        char_counter <= char_counter + 1;
                        current_char <= message[char_counter + 1];
                        state <= START;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
