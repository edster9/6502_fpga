// Tutorial Step 3: PWM Brightness Control
// Use PWM to create breathing effect on LED

module step3 (
    input clk,          // 27MHz clock input
    output led_r,       // Red LED output (PWM controlled)
    output led_g,       // Green LED (off)
    output led_b        // Blue LED (off)
);

    // PWM counter (8-bit for 256 levels)
    reg [7:0] pwm_counter;
    reg [7:0] brightness;
    reg [15:0] breath_counter;
    reg direction;
    
    // Keep green and blue LEDs off
    assign led_g = 1'b0;
    assign led_b = 1'b0;
    
    // PWM generation
    assign led_r = (pwm_counter < brightness);
    
    always @(posedge clk) begin
        // Fast PWM counter (27MHz / 256 = ~105kHz PWM frequency)
        pwm_counter <= pwm_counter + 1;
        
        // Slower breathing effect counter
        breath_counter <= breath_counter + 1;
        
        // Update brightness every 65536 clock cycles
        if (breath_counter == 16'd0) begin
            if (direction) begin
                if (brightness == 8'd255)
                    direction <= 1'b0;
                else
                    brightness <= brightness + 1;
            end else begin
                if (brightness == 8'd0)
                    direction <= 1'b1;
                else
                    brightness <= brightness - 1;
            end
        end
    end

endmodule
