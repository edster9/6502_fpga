`timescale 1ns / 1ps

// Testbench for top
module top_tb ();

  // Testbench signals
  reg tb_clk;

  // Clock period (adjust based on your board)
  parameter CLK_PERIOD = 83.33;  // 12MHz = 83.33ns period

  // Instantiate the Unit Under Test (UUT)
  top uut (
      .i_Clk(tb_clk)
      // Connect your ports here
  );

  // Clock generation
  always begin
    tb_clk = 1'b0;
    #(CLK_PERIOD / 2);
    tb_clk = 1'b1;
    #(CLK_PERIOD / 2);
  end

  // Test sequence
  initial begin
    // Wait for reset
    #(CLK_PERIOD * 10);

    $display("Starting top testbench...");

    // Add your test logic here

    $display("Testbench completed!");
    $finish;
  end

  // VCD dump for waveform viewing
  initial begin
    $dumpfile("projects/simulate_ice40/build/top_tb.vcd");
    $dumpvars(0, top_tb);
  end

endmodule
