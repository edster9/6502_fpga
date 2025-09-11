// UART Verilog Project
// Button-controlled UART messaging with LED feedback

module uart (
    input wire clk,          // 27MHz clock from Tang Nano 20K
    input wire btn1,         // Button 1 (active low)
    input wire btn2,         // Button 2 (active low)
    output wire led_r,       // Red LED (for btn1)
    output wire led_g,       // Green LED (for btn2)
    output wire led_b,       // Blue LED (unused)
    output wire uart_tx      // UART TX for debug output
);

    // Button debouncing and edge detection
    reg [2:0] btn1_sync;
    reg [2:0] btn2_sync;
    reg btn1_pressed, btn2_pressed;
    
    // LED control
    reg led1_on, led2_on;
    
    // Button synchronization and edge detection
    always @(posedge clk) begin
        // Synchronize buttons (active low, so invert)
        btn1_sync <= {btn1_sync[1:0], ~btn1};
        btn2_sync <= {btn2_sync[1:0], ~btn2};
        
        // Detect button press (rising edge after synchronization)
        btn1_pressed <= (btn1_sync[2:1] == 2'b01);
        btn2_pressed <= (btn2_sync[2:1] == 2'b01);
        
        // LED control - on while button is pressed
        led1_on <= btn1_sync[2];
        led2_on <= btn2_sync[2];
    end
    
    // Connect LEDs (inverted because LEDs are active low on Tang Nano)
    assign led_r = ~led1_on;     // Red LED for button 1
    assign led_g = ~led2_on;     // Green LED for button 2
    assign led_b = 1'b1;         // Blue LED off
    
    // UART Debug Module Instance
    uart_debug debug_uart_inst (
        .clk(clk),
        .reset(1'b0),
        .uart_tx(uart_tx),
        .btn1_trigger(btn1_pressed),
        .btn2_trigger(btn2_pressed)
    );
    
    /* 
    Learning Notes:
    
    1. MODULES: Everything in Verilog is a module (like a function in other languages)
    2. INPUTS/OUTPUTS: Define the interface to your module
    3. WIRE vs REG: 
       - wire: connects things together (like actual wires)
       - reg: stores values (like variables in other languages)
             * Allocated in FPGA fabric (flip-flops/registers), NOT external RAM
             * Each reg becomes physical storage elements (D flip-flops)
             * For actual RAM/memory blocks, use different constructs
    4. ALWAYS BLOCKS: Code that runs when something happens (@posedge clk = on clock edge)
    5. ASSIGN: Continuous assignment (always active, like gates)
    6. MODULE INSTANCES: Using other modules inside your design (like calling functions)
    
    MEMORY HIERARCHY:
    - reg variables -> FPGA fabric registers (fast, limited quantity)
    - Arrays like button1_msg[0:8] -> BRAM blocks (block RAM inside FPGA)
    - External DRAM/SRAM -> requires memory controllers (not used in this project)
    
    UART PROJECT: Button-controlled messaging!
    - Press button 1 -> sends "button1" + lights red LED
    - Press button 2 -> sends "button2" + lights green LED
    - Uses built-in USB-serial converter at 115200 baud
    - See messages in terminal (PuTTY, etc.) connected to Tang Nano COM port
    */

endmodule

// Simple UART Debug Module - Button Message Version
module uart_debug (
    input wire clk,              // 27MHz system clock
    input wire reset,            // Reset signal
    output reg uart_tx,          // UART TX pin
    input wire btn1_trigger,     // Button 1 press trigger
    input wire btn2_trigger      // Button 2 press trigger
);

    // UART parameters for 115200 baud at 27MHz
    parameter BAUD_DIVISOR = 234; // 27,000,000 / 115200 ≈ 234
    
    // State machine
    reg [2:0] state;
    reg [7:0] baud_counter;
    reg [3:0] bit_counter;
    reg [3:0] char_counter;
    reg [7:0] current_char;
    reg [3:0] message_length;
    reg [3:0] current_message;
    
    // States
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3, NEXT = 4;
    
    // Message selection
    parameter MSG_BUTTON1 = 0, MSG_BUTTON2 = 1;
    
    // Message arrays
    reg [7:0] button1_msg [0:8];  // "button1\r\n" = 9 characters
    reg [7:0] button2_msg [0:8];  // "button2\r\n" = 9 characters
    
    initial begin
        // Button1 message: "button1\r\n"
        button1_msg[0] = "b";
        button1_msg[1] = "u";
        button1_msg[2] = "t";
        button1_msg[3] = "t";
        button1_msg[4] = "o";
        button1_msg[5] = "n";
        button1_msg[6] = "1";
        button1_msg[7] = 8'h0D; // \r
        button1_msg[8] = 8'h0A; // \n
        
        // Button2 message: "button2\r\n"
        button2_msg[0] = "b";
        button2_msg[1] = "u";
        button2_msg[2] = "t";
        button2_msg[3] = "t";
        button2_msg[4] = "o";
        button2_msg[5] = "n";
        button2_msg[6] = "2";
        button2_msg[7] = 8'h0D; // \r
        button2_msg[8] = 8'h0A; // \n
    end
    
    // Main UART logic
    always @(posedge clk) begin
        if (reset) begin
            uart_tx <= 1'b1;
            state <= IDLE;
            baud_counter <= 0;
            bit_counter <= 0;
            char_counter <= 0;
            message_length <= 0;
            current_message <= 0;
        end else begin
            case (state)
                IDLE: begin
                    uart_tx <= 1'b1;
                    baud_counter <= 0;
                    
                    // Check for button triggers
                    if (btn1_trigger) begin
                        char_counter <= 0;
                        current_message <= MSG_BUTTON1;
                        message_length <= 8; // 9-1 for 0-indexed
                        current_char <= button1_msg[0];
                        state <= START;
                    end else if (btn2_trigger) begin
                        char_counter <= 0;
                        current_message <= MSG_BUTTON2;
                        message_length <= 8; // 9-1 for 0-indexed
                        current_char <= button2_msg[0];
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
                    if (char_counter >= message_length) begin
                        state <= IDLE;
                    end else begin
                        char_counter <= char_counter + 1;
                        // Select next character based on current message
                        if (current_message == MSG_BUTTON1) begin
                            current_char <= button1_msg[char_counter + 1];
                        end else begin
                            current_char <= button2_msg[char_counter + 1];
                        end
                        state <= START;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
