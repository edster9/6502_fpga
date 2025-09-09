// Simple UART Debug Module
// Sends debug messages over UART at 115200 baud

module uart_debug_simple (
    input wire clk,              // 27MHz system clock
    input wire reset,            // Reset signal (active high)
    output reg uart_tx,          // UART TX output
    input wire debug_trigger,    // Trigger to send debug message
    input wire [23:0] counter_value  // Counter value to send
);

    // UART Parameters for 115200 baud at 27MHz
    // Baud rate = 27,000,000 / 115200 ≈ 234 clock cycles per bit
    parameter BAUD_DIVISOR = 234;
    parameter IDLE = 1'b1;
    parameter START_BIT = 1'b0;
    parameter STOP_BIT = 1'b1;
    
    // State machine states
    parameter STATE_IDLE = 0;
    parameter STATE_SENDING = 1;
    
    // Message components
    parameter MSG_LENGTH = 24;  // "Hello! Counter: 0x?????\r\n"
    
    reg state;
    reg [7:0] baud_counter;
    reg [3:0] bit_counter;
    reg [4:0] char_counter;
    reg debug_trigger_prev;
    
    // Message ROM
    reg [7:0] message [0:MSG_LENGTH-1];
    initial begin
        message[0]  = 8'h48;  // 'H'
        message[1]  = 8'h65;  // 'e'
        message[2]  = 8'h6C;  // 'l'
        message[3]  = 8'h6C;  // 'l'
        message[4]  = 8'h6F;  // 'o'
        message[5]  = 8'h21;  // '!'
        message[6]  = 8'h20;  // ' '
        message[7]  = 8'h43;  // 'C'
        message[8]  = 8'h6F;  // 'o'
        message[9]  = 8'h75;  // 'u'
        message[10] = 8'h6E;  // 'n'
        message[11] = 8'h74;  // 't'
        message[12] = 8'h65;  // 'e'
        message[13] = 8'h72;  // 'r'
        message[14] = 8'h3A;  // ':'
        message[15] = 8'h20;  // ' '
        message[16] = 8'h30;  // '0'
        message[17] = 8'h78;  // 'x'
        message[18] = 8'h30;  // '0' (will be replaced with hex digits)
        message[19] = 8'h30;  // '0'
        message[20] = 8'h30;  // '0'
        message[21] = 8'h30;  // '0'
        message[22] = 8'h0D;  // '\r'
        message[23] = 8'h0A;  // '\n'
    end
    
    // Current character being sent
    reg [7:0] current_char;
    reg [7:0] shift_reg;
    
    // Convert 4-bit value to ASCII hex
    function [7:0] hex_to_ascii;
        input [3:0] hex_val;
        begin
            if (hex_val < 10)
                hex_to_ascii = 8'h30 + hex_val;  // '0' to '9'
            else
                hex_to_ascii = 8'h41 + hex_val - 10;  // 'A' to 'F'
        end
    endfunction
    
    always @(posedge clk) begin
        if (reset) begin
            uart_tx <= IDLE;
            state <= STATE_IDLE;
            baud_counter <= 0;
            bit_counter <= 0;
            char_counter <= 0;
            debug_trigger_prev <= 0;
        end else begin
            debug_trigger_prev <= debug_trigger;
            
            case (state)
                STATE_IDLE: begin
                    uart_tx <= IDLE;
                    // Detect rising edge of debug_trigger
                    if (debug_trigger && !debug_trigger_prev) begin
                        state <= STATE_SENDING;
                        char_counter <= 0;
                        // Set up first character
                        current_char <= message[0];
                        shift_reg <= {message[0], START_BIT};  // LSB first: start bit, then data
                        bit_counter <= 0;
                        baud_counter <= 0;
                    end
                end
                
                STATE_SENDING: begin
                    if (baud_counter >= BAUD_DIVISOR - 1) begin
                        baud_counter <= 0;
                        
                        if (bit_counter == 0) begin
                            // Send start bit
                            uart_tx <= START_BIT;
                            bit_counter <= bit_counter + 1;
                        end else if (bit_counter <= 8) begin
                            // Send data bits
                            uart_tx <= shift_reg[bit_counter - 1];
                            bit_counter <= bit_counter + 1;
                        end else begin
                            // Send stop bit
                            uart_tx <= STOP_BIT;
                            
                            // Move to next character
                            char_counter <= char_counter + 1;
                            if (char_counter >= MSG_LENGTH - 1) begin
                                // Message complete
                                state <= STATE_IDLE;
                            end else begin
                                // Set up next character
                                bit_counter <= 0;
                                
                                // Handle hex digit replacement
                                if (char_counter == 17) begin  // First hex digit
                                    current_char <= hex_to_ascii(counter_value[23:20]);
                                end else if (char_counter == 18) begin  // Second hex digit
                                    current_char <= hex_to_ascii(counter_value[19:16]);
                                end else if (char_counter == 19) begin  // Third hex digit
                                    current_char <= hex_to_ascii(counter_value[15:12]);
                                end else if (char_counter == 20) begin  // Fourth hex digit
                                    current_char <= hex_to_ascii(counter_value[11:8]);
                                end else begin
                                    current_char <= message[char_counter + 1];
                                end
                                
                                shift_reg <= {current_char, START_BIT};
                            end
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
            endcase
        end
    end

endmodule
