// Backup of original playground.v for Lattice iCE40
// ...existing code will be copied from playground.v...

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

/*
module playground
  (input i_Switch_1,  
   input i_Switch_2,
   input i_Switch_3,
   input i_Switch_4,
   output o_LED_1,
   output o_LED_2,
   output o_LED_3,
   output o_LED_4);
       
assign o_LED_1 = i_Switch_1;
assign o_LED_2 = i_Switch_2;
assign o_LED_3 = i_Switch_3;
assign o_LED_4 = i_Switch_4;

endmodule
*/

/*
module playground
    (input i_Clk,
    input i_Switch_1,
    output o_LED_1);

    reg r_LED_1 = 1'b0;
    reg r_Switch_1 = 1'b0;
    wire w_Switch_1;

    Debounce_Single_Input #(250000) db1
    (
        .i_Clk(i_Clk),
        .i_Switch(i_Switch_1),
        .o_Switch(w_Switch_1)
    );

    always @(posedge i_Clk) 
        begin
            r_Switch_1 <= w_Switch_1;

            if (w_Switch_1 == 1'b0 && r_Switch_1 == 1'b1) 
                begin
                    r_LED_1 <= ~r_LED_1; // Toggle LED on switch press
                end
        end

assign o_LED_1 = r_LED_1;

endmodule
*/

module playground
  (input  i_Clk,      // Main Clock (25 MHz)
   input  i_Switch_1,
   input  i_Switch_2, 
   output o_Segment1_A,
   output o_Segment1_B,
   output o_Segment1_C,
   output o_Segment1_D,
   output o_Segment1_E,
   output o_Segment1_F,
   output o_Segment1_G,
   output o_Segment2_A,
   output o_Segment2_B,
   output o_Segment2_C,
   output o_Segment2_D,
   output o_Segment2_E,
   output o_Segment2_F,
   output o_Segment2_G
   );
 
  wire w_Switch_1;
  reg  r_Switch_1 = 1'b0;
  wire w_Switch_2;
  reg  r_Switch_2 = 1'b0;
  reg [3:0] r_Count1 = 4'b0000;
  reg [3:0] r_Count2 = 4'b0000;

    wire w_Segment1_A;
    wire w_Segment1_B;
    wire w_Segment1_C;
    wire w_Segment1_D;
    wire w_Segment1_E;
    wire w_Segment1_F;
    wire w_Segment1_G;
  wire w_Segment2_A;
  wire w_Segment2_B;
  wire w_Segment2_C;
  wire w_Segment2_D;
  wire w_Segment2_E;
  wire w_Segment2_F;
  wire w_Segment2_G;
 
  // Instantiate Debounce Filter
  Debounce_Single_Input Debounce_Switch_Inst1
    (.i_Clk(i_Clk),
     .i_Switch(i_Switch_1),
     .o_Switch(w_Switch_1));
  
    Debounce_Single_Input Debounce_Switch_Inst2
    (.i_Clk(i_Clk),
     .i_Switch(i_Switch_2),
     .o_Switch(w_Switch_2));
  
  // Purpose: When Switch is pressed, increment counter.
  // When counter gets to 15, start it back at 0 again.
  always @(posedge i_Clk)
  begin
    r_Switch_1 <= w_Switch_1;
    r_Switch_2 <= w_Switch_2;
       
      // Increment Count1 when switch1 is pushed down
      if (w_Switch_1 == 1'b1 && r_Switch_1 == 1'b0)
      begin
        if (r_Count1 == 15)
          r_Count1 <= 0;
        else
          r_Count1 <= r_Count1 + 1;
      end
      
      // Increment Count2 when switch2 is pushed down
      if (w_Switch_2 == 1'b1 && r_Switch_2 == 1'b0)
      begin
        if (r_Count2 == 15)
          r_Count2 <= 0;
        else
          r_Count2 <= r_Count2 + 1;
      end
  end
   
  // Instantiate Binary to 7-Segment Converter
  Binary_To_7Segment Inst1
    (.i_Clk(i_Clk),
     .i_Binary_Num(r_Count1),
     .o_Segment_A(w_Segment1_A),
     .o_Segment_B(w_Segment1_B),
     .o_Segment_C(w_Segment1_C),
     .o_Segment_D(w_Segment1_D),
     .o_Segment_E(w_Segment1_E),
     .o_Segment_F(w_Segment1_F),
     .o_Segment_G(w_Segment1_G)
     );
  
  Binary_To_7Segment Inst2
    (.i_Clk(i_Clk),
     .i_Binary_Num(r_Count2),
     .o_Segment_A(w_Segment2_A),
     .o_Segment_B(w_Segment2_B),
     .o_Segment_C(w_Segment2_C),
     .o_Segment_D(w_Segment2_D),
     .o_Segment_E(w_Segment2_E),
     .o_Segment_F(w_Segment2_F),
     .o_Segment_G(w_Segment2_G)
     );
  
  assign o_Segment1_A = ~w_Segment1_A;
  assign o_Segment1_B = ~w_Segment1_B;
  assign o_Segment1_C = ~w_Segment1_C;
  assign o_Segment1_D = ~w_Segment1_D;
  assign o_Segment1_E = ~w_Segment1_E;
  assign o_Segment1_F = ~w_Segment1_F;
  assign o_Segment1_G = ~w_Segment1_G;
  
  assign o_Segment2_A = ~w_Segment2_A;
  assign o_Segment2_B = ~w_Segment2_B;
  assign o_Segment2_C = ~w_Segment2_C;
  assign o_Segment2_D = ~w_Segment2_D;
  assign o_Segment2_E = ~w_Segment2_E;
  assign o_Segment2_F = ~w_Segment2_F;
  assign o_Segment2_G = ~w_Segment2_G;
   
endmodule