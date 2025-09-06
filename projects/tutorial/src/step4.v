// Tutorial Step 4: Button Debouncing (Placeholder)
// This would demonstrate button input handling
// Note: Tang Nano doesn't have built-in buttons, so this is for external buttons

module step4 (
    input clk,          // 27MHz clock input
    input button,       // External button input (if connected)
    output reg led_r,   // Red LED output
    output reg led_g,   // Green LED output 
    output led_b        // Blue LED (off)
);

    // Since we don't have a physical button, simulate button presses
    reg [25:0] sim_counter;
    reg sim_button;
    
    // Button debouncer
    reg [2:0] button_sync;
    reg button_debounced;
    reg button_prev;
    wire button_pressed;
    
    // Keep blue LED off
    assign led_b = 1'b0;
    
    // Simulate button presses every 2 seconds
    always @(posedge clk) begin
        sim_counter <= sim_counter + 1;
        if (sim_counter == 26'd53_999_999) begin  // 2 seconds
            sim_counter <= 26'd0;
            sim_button <= ~sim_button;
        end
    end
    
    // Use simulated button if no physical button connected
    wire actual_button = button | sim_button;
    
    // Synchronizer and debouncer
    always @(posedge clk) begin
        button_sync <= {button_sync[1:0], actual_button};
        button_debounced <= &button_sync;  // All bits high = button pressed
        button_prev <= button_debounced;
    end
    
    assign button_pressed = button_debounced & ~button_prev;  // Rising edge
    
    // Toggle LEDs on button press
    always @(posedge clk) begin
        if (button_pressed) begin
            led_r <= ~led_r;
            led_g <= ~led_g;
        end
    end

endmodule
