// Very Simple UART Test Module
// Just sends "A\r\n" repeatedly to test basic UART functionality

module simple_uart (
    input wire clk,              // 27MHz system clock
    input wire reset,            // Reset signal (active high)
    output reg uart_tx,          // UART TX output
    input wire debug_trigger     // Trigger to send message
);

    // UART Parameters for 115200 baud at 27MHz
    // Baud rate = 27,000,000 / 115200 ≈ 234 clock cycles per bit
    parameter BAUD_DIVISOR = 234;
    
    // State machine states
    parameter STATE_IDLE = 0;
    parameter STATE_START = 1;
    parameter STATE_DATA = 2;
    parameter STATE_STOP = 3;
    
    // Simple message: "A\r\n"
    parameter MSG_LENGTH = 3;
    reg [7:0] message [0:MSG_LENGTH-1];
    initial begin
        message[0] = 8'h41;  // 'A'
        message[1] = 8'h0D;  // '\r'
        message[2] = 8'h0A;  // '\n'
    end
    
    reg [1:0] state;
    reg [7:0] baud_counter;
    reg [2:0] bit_counter;
    reg [1:0] char_counter;
    reg debug_trigger_prev;
    reg [7:0] current_char;
    
    always @(posedge clk) begin
        if (reset) begin
            uart_tx <= 1'b1;  // IDLE state
            state <= STATE_IDLE;
            baud_counter <= 0;
            bit_counter <= 0;
            char_counter <= 0;
            debug_trigger_prev <= 0;
        end else begin
            debug_trigger_prev <= debug_trigger;
            
            case (state)
                STATE_IDLE: begin
                    uart_tx <= 1'b1;  // IDLE high
                    // Detect rising edge of debug_trigger
                    if (debug_trigger && !debug_trigger_prev) begin
                        state <= STATE_START;
                        char_counter <= 0;
                        current_char <= message[0];
                        baud_counter <= 0;
                    end
                end
                
                STATE_START: begin
                    if (baud_counter >= BAUD_DIVISOR - 1) begin
                        uart_tx <= 1'b0;  // Start bit
                        state <= STATE_DATA;
                        bit_counter <= 0;
                        baud_counter <= 0;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                STATE_DATA: begin
                    if (baud_counter >= BAUD_DIVISOR - 1) begin
                        uart_tx <= current_char[bit_counter];  // Send data bit (LSB first)
                        baud_counter <= 0;
                        if (bit_counter >= 7) begin
                            state <= STATE_STOP;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                STATE_STOP: begin
                    if (baud_counter >= BAUD_DIVISOR - 1) begin
                        uart_tx <= 1'b1;  // Stop bit
                        baud_counter <= 0;
                        
                        // Move to next character
                        if (char_counter >= MSG_LENGTH - 1) begin
                            // Message complete, go back to idle
                            state <= STATE_IDLE;
                        end else begin
                            // Next character
                            char_counter <= char_counter + 1;
                            current_char <= message[char_counter + 1];
                            state <= STATE_START;
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
