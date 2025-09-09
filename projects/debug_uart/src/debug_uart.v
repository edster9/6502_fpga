// Debug UART Verilog Project
// LED counter with UART debug output for learning hardware debugging

module debug_uart (
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

// Simple UART Debug Module for Learning
// Sends counter values as ASCII text to serial terminal
module uart_debug_simple (
    input wire clk,              // 27MHz system clock
    input wire reset,            // Reset signal
    output reg uart_tx,          // UART TX pin
    input wire debug_trigger,    // When to send debug message
    input wire [23:0] counter_value // Counter value to transmit
);

    // UART parameters for 115200 baud at 27MHz
    localparam UART_DIVIDER = 234; // 27,000,000 / 115200 ≈ 234
    
    // State machine for sending debug messages
    reg [4:0] state;
    reg [15:0] uart_timer;
    reg [3:0] char_index;
    reg [7:0] current_char;
    reg debug_trigger_prev;
    
    // States for the debug output state machine
    localparam IDLE = 0, START_MSG = 1, SEND_CHAR = 2, WAIT_CHAR = 3, NEXT_CHAR = 4;
    
    // Debug message: "Hello! Counter: XXXXXX\r\n"
    reg [7:0] debug_message [0:23];
    
    // Initialize the debug message
    initial begin
        debug_message[0]  = "H";  debug_message[1]  = "e";  debug_message[2]  = "l";
        debug_message[3]  = "l";  debug_message[4]  = "o";  debug_message[5]  = "!";
        debug_message[6]  = " ";  debug_message[7]  = "C";  debug_message[8]  = "o";
        debug_message[9]  = "u";  debug_message[10] = "n";  debug_message[11] = "t";
        debug_message[12] = "e";  debug_message[13] = "r";  debug_message[14] = ":";
        debug_message[15] = " ";  debug_message[16] = "0";  debug_message[17] = "x";
        debug_message[18] = "0";  debug_message[19] = "0";  debug_message[20] = "0";
        debug_message[21] = "0";  debug_message[22] = 13;   debug_message[23] = 10;
        // Positions 18-21 will be filled with hex counter values
        // Position 22 = \r (carriage return), Position 23 = \n (line feed)
    end
    
    // Edge detection for debug trigger
    always @(posedge clk) begin
        debug_trigger_prev <= debug_trigger;
    end
    
    wire debug_edge = debug_trigger && !debug_trigger_prev;
    
    // Main debug state machine
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            uart_tx <= 1'b1;  // UART idle high
            uart_timer <= 0;
            char_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    uart_tx <= 1'b1;
                    if (debug_edge) begin
                        // Convert counter to hex and update message
                        debug_message[18] <= hex_to_ascii(counter_value[15:12]);
                        debug_message[19] <= hex_to_ascii(counter_value[11:8]);
                        debug_message[20] <= hex_to_ascii(counter_value[7:4]);
                        debug_message[21] <= hex_to_ascii(counter_value[3:0]);
                        char_index <= 0;
                        state <= START_MSG;
                    end
                end
                
                START_MSG: begin
                    current_char <= debug_message[char_index];
                    state <= SEND_CHAR;
                    uart_timer <= 0;
                end
                
                SEND_CHAR: begin
                    // Send start bit
                    if (uart_timer == 0) begin
                        uart_tx <= 1'b0; // Start bit
                    end
                    // Send data bits
                    else if (uart_timer >= UART_DIVIDER && uart_timer < 9 * UART_DIVIDER) begin
                        uart_tx <= current_char[(uart_timer - UART_DIVIDER) / UART_DIVIDER];
                    end
                    // Send stop bit
                    else if (uart_timer >= 9 * UART_DIVIDER) begin
                        uart_tx <= 1'b1; // Stop bit
                    end
                    
                    if (uart_timer < 10 * UART_DIVIDER - 1) begin
                        uart_timer <= uart_timer + 1;
                    end else begin
                        uart_timer <= 0;
                        state <= NEXT_CHAR;
                    end
                end
                
                NEXT_CHAR: begin
                    if (char_index < 23) begin
                        char_index <= char_index + 1;
                        state <= START_MSG;
                    end else begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
    // Function to convert 4-bit hex to ASCII
    function [7:0] hex_to_ascii;
        input [3:0] hex_val;
        begin
            hex_to_ascii = (hex_val < 10) ? (8'h30 + hex_val) : (8'h37 + hex_val);
        end
    endfunction

endmodule
