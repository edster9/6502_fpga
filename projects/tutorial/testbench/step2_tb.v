`timescale 1ns / 1ns

module step2_tb;

    // Inputs
    reg [1:0] A;
    reg [1:0] B;
    
    // Outputs
    wire F;
    
    // Instantiate the Unit Under Test (UUT)
    step2 uut(A, B, F);
    
    initial begin
        $dumpfile("build/tutorial_step2.vcd");
        $dumpvars(0, step2_tb);
        
        // Display header
        $display("Testing 2-bit Comparator (A > B)");
        $display("A  B  | F | Expected | A>B?");
        $display("------|---|----------|-----");
        
        // Test all 16 combinations systematically
        A = 2'b00; B = 2'b00; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b00; B = 2'b01; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b00; B = 2'b10; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b00; B = 2'b11; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        
        A = 2'b01; B = 2'b00; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b01; B = 2'b01; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b01; B = 2'b10; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b01; B = 2'b11; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        
        A = 2'b10; B = 2'b00; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b10; B = 2'b01; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b10; B = 2'b10; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b10; B = 2'b11; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        
        A = 2'b11; B = 2'b00; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b11; B = 2'b01; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b11; B = 2'b10; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        A = 2'b11; B = 2'b11; #10; $display("%d  %d  | %b |    %b     | %s", A, B, F, (A > B), (A > B) ? "Yes" : "No");
        
        $display("\nSimulation completed - Check that F matches Expected!");
        $finish;
    end

endmodule
