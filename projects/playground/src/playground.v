/*
module playground
(
    input clk,
    output [5:0] led
);

// Clock divider for different boards
// Tang Nano 9K/20K: 27MHz -> 13500000 for ~0.5Hz
// iCE40 boards: 12MHz -> 6000000 for ~0.5Hz  
`ifdef ICE40
localparam WAIT_TIME = 6000000;  // 12MHz / 6M = 2Hz, so 0.5Hz toggle
`else
localparam WAIT_TIME = 13500000; // 27MHz / 13.5M = 2Hz, so 0.5Hz toggle
`endif

reg [5:0] ledCounter = 0;
reg [23:0] clockCounter = 0;

always @(posedge clk) begin
    clockCounter <= clockCounter + 1;
    if (clockCounter == WAIT_TIME) begin
        clockCounter <= 0;
        ledCounter <= ledCounter + 1;
    end
end

assign led = ledCounter;
endmodule
*/

module playground
  (input i_Switch_1,  
   input i_Switch_2,
   input i_Switch_3,
   input i_Switch_4,
   output o_LED_1,
   output o_LED_2,
   output o_LED_3,
   output o_LED_4);
       
assign o_LED_1 = 1'b1;        // ON - Clear SRAM test
assign o_LED_2 = 1'b0;        // OFF - Clear SRAM test  
assign o_LED_3 = 1'b1;        // ON - Clear SRAM test
assign o_LED_4 = 1'b0;        // OFF - Clear SRAM test

endmodule