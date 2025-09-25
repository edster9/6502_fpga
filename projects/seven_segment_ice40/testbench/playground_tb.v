`timescale 1ns / 1ps

module playground_tb ();

  // Testbench signals
  reg tb_clk;
  reg tb_switch_1;
  reg tb_switch_2;

  wire tb_segment1_a, tb_segment1_b, tb_segment1_c, tb_segment1_d;
  wire tb_segment1_e, tb_segment1_f, tb_segment1_g;
  wire tb_segment2_a, tb_segment2_b, tb_segment2_c, tb_segment2_d;
  wire tb_segment2_e, tb_segment2_f, tb_segment2_g;

  // Instantiate the Unit Under Test (UUT)
  playground uut (
      .i_Clk(tb_clk),
      .i_Switch_1(tb_switch_1),
      .i_Switch_2(tb_switch_2),
      .o_Segment1_A(tb_segment1_a),
      .o_Segment1_B(tb_segment1_b),
      .o_Segment1_C(tb_segment1_c),
      .o_Segment1_D(tb_segment1_d),
      .o_Segment1_E(tb_segment1_e),
      .o_Segment1_F(tb_segment1_f),
      .o_Segment1_G(tb_segment1_g),
      .o_Segment2_A(tb_segment2_a),
      .o_Segment2_B(tb_segment2_b),
      .o_Segment2_C(tb_segment2_c),
      .o_Segment2_D(tb_segment2_d),
      .o_Segment2_E(tb_segment2_e),
      .o_Segment2_F(tb_segment2_f),
      .o_Segment2_G(tb_segment2_g)
  );

  // Clock generation (12MHz for ice40)
  always begin
    tb_clk = 1'b0;
    #41.67;  // 12MHz = 83.33ns period, half period = 41.67ns
    tb_clk = 1'b1;
    #41.67;
  end

  // Test sequence
  initial begin
    // Initialize Inputs
    tb_switch_1 = 0;
    tb_switch_2 = 0;

    // Wait for global reset
    #200;

    $display("Starting 7-segment display test...");

    // Test switch 1 press (increment counter 1)
    $display("Testing switch 1 press...");
    tb_switch_1 = 1;
    #1000;  // Hold for 1us (much shorter)
    tb_switch_1 = 0;
    #5000;  // Wait 5us for debounce to settle

    // Test switch 2 press (increment counter 2)
    $display("Testing switch 2 press...");
    tb_switch_2 = 1;
    #1000;  // Hold for 1us
    tb_switch_2 = 0;
    #5000;  // Wait 5us

    // Test multiple presses
    $display("Testing multiple switch presses...");
    repeat (3) begin
      tb_switch_1 = 1;
      #1000;
      tb_switch_1 = 0;
      #5000;
    end

    repeat (2) begin
      tb_switch_2 = 1;
      #1000;
      tb_switch_2 = 0;
      #5000;
    end

    // Let it run a bit more
    #10000;

    $display("Simulation completed!");
    $finish;
  end

  // Monitor the 7-segment outputs (only on changes)
  reg [6:0] prev_seg1, prev_seg2;
  always @(posedge tb_clk) begin
    // Create current segment values for comparison
    reg [6:0] current_seg1 = {
      tb_segment1_a,
      tb_segment1_b,
      tb_segment1_c,
      tb_segment1_d,
      tb_segment1_e,
      tb_segment1_f,
      tb_segment1_g
    };
    reg [6:0] current_seg2 = {
      tb_segment2_a,
      tb_segment2_b,
      tb_segment2_c,
      tb_segment2_d,
      tb_segment2_e,
      tb_segment2_f,
      tb_segment2_g
    };

    // Check if either segment has changed
    if (current_seg1 !== prev_seg1 || current_seg2 !== prev_seg2) begin
      $display("Time: %0t | Seg1: %b | Seg2: %b", $time, current_seg1, current_seg2);
      prev_seg1 = current_seg1;
      prev_seg2 = current_seg2;
    end
  end

  // VCD dump for waveform viewing
  initial begin
    $dumpfile("projects/seven_segment_ice40/playground_tb.vcd");
    $dumpvars(0, playground_tb);
  end

endmodule
