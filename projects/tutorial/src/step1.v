// Tutorial Step 1: Basic LED Toggle
// Simple LED that toggles every second


module step1 (A, B);
  input A;
  output B;
  assign B = A;
endmodule

/*
module step1 (
    input clk,          // 27MHz clock input
    output reg led_r,   // Red LED output
    output led_g,       // Green LED (off)
    output led_b        // Blue LED (off)
);

    // Counter for 1 second delay (27MHz / 27,000,000 = 1Hz)
    reg [24:0] counter;
    
    // Keep green and blue LEDs off
    assign led_g = 1'b0;
    assign led_b = 1'b0;
    
    always @(posedge clk) begin
        counter <= counter + 1;
        
        // Toggle red LED every second
        if (counter == 25'd26_999_999) begin
            counter <= 25'd0;
            led_r <= ~led_r;
        end
    end

endmodule
*/
