`timescale 1ns / 1ps

// Testbench for cpu_core
module cpu_core_tb ();

    // Testbench signals
    reg tb_clk;
    
    // Clock period (adjust based on your board)
    parameter CLK_PERIOD = 83.33; // 12MHz = 83.33ns period
    
    // Instantiate the Unit Under Test (UUT)
    cpu_core uut (
        .i_Clk(tb_clk)
        // Connect your ports here
    );
    
    // Clock generation
    always begin
        tb_clk = 1'b0;
        #(CLK_PERIOD/2);
        tb_clk = 1'b1;
        #(CLK_PERIOD/2);
    end
    
    // Test sequence
    initial begin
        // Wait for reset
        #(CLK_PERIOD * 10);
        
        $display("Starting cpu_core testbench...");
        
        // Add your test logic here
        
        $display("Testbench completed!");
        $finish;
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("projects/test_project/build/cpu_core_tb.vcd");
        $dumpvars(0, cpu_core_tb);
    end
    
endmodule
