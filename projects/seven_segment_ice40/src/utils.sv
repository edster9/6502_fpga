// Simple SystemVerilog utility module demonstrating SV features
// This module shows SystemVerilog syntax without breaking existing functionality

// SystemVerilog module with logic data type and always_ff
module utils (
    input  logic       clk,
    input  logic       reset,
    input  logic [2:0] digit_in,     // SystemVerilog logic type
    output logic [6:0] segments_out
);

  // SystemVerilog always_ff block (instead of always @(posedge clk))
  always_ff @(posedge clk) begin
    if (reset) begin
      segments_out <= 7'b0000000;
    end else begin
      // Simple case statement to demonstrate SystemVerilog
      case (digit_in)
        3'd0: segments_out <= 7'b0111111;  // 0
        3'd1: segments_out <= 7'b0000110;  // 1
        3'd2: segments_out <= 7'b1011011;  // 2
        3'd3: segments_out <= 7'b1001111;  // 3
        3'd4: segments_out <= 7'b1100110;  // 4
        3'd5: segments_out <= 7'b1101101;  // 5
        3'd6: segments_out <= 7'b1111101;  // 6
        3'd7: segments_out <= 7'b0000111;  // 7
        default: segments_out <= 7'b0000000;
      endcase
    end
  end

  // SystemVerilog always_comb for validation
  logic valid_digit;
  always_comb begin
    valid_digit = (digit_in <= 3'd7);
  end

endmodule

