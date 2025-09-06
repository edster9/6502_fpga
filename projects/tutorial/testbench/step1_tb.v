`timescale 1ns / 1ns
/*`include "step1.v"*/

module step1_tb;

reg A;
wire B;

step1 uut(A, B);

initial begin
    $dumpfile("build/tutorial_step1.vcd");
    $dumpvars(0, step1_tb);

    // Test sequence
    A = 0;
    #20; // Wait 20ns
    A = 1;
    #20; // Wait 20ns
    A = 0;
    #20; // Wait 20ns
    
    $display("Simulation completed");
end

endmodule