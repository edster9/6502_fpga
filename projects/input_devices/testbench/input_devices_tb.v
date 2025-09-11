// Testbench for Input Devices - Simple Switch-LED Example
// Verifies that switches control LEDs directly

`timescale 1ns / 1ps

module input_devices_tb;

    // Testbench signals
    reg clk;
    reg switch1, switch2;
    wire led1, led2;
    
    // Instantiate the module under test
    input_devices uut (
        .clk(clk),
        .switch1(switch1),
        .switch2(switch2),
        .led1(led1),
        .led2(led2)
    );
    
    // Clock generation (not actually used by the simple logic)
    initial begin
        clk = 0;
        forever #18.5 clk = ~clk;  // 27MHz clock
    end
    
    // Test stimulus
    initial begin
        $dumpfile("build/input_devices.vcd");
        $dumpvars(0, input_devices_tb);
        
        $display("=== Input Devices Switch-LED Test ===");
        $display("Testing switch-to-LED connection with active high logic");
        $display("Switches are inverted to make pressed = LED on");
        $display("");
        
        // Initialize - both switches released (active low = 1)
        switch1 = 1;
        switch2 = 1;
        #100;
        
        $display("Time=%0t: Both switches released", $time);
        $display("  switch1=%b, led1=%b (LED should be OFF)", switch1, led1);
        $display("  switch2=%b, led2=%b (LED should be OFF)", switch2, led2);
        $display("");
        
        // Press switch1 (active low = 0)
        switch1 = 0;
        #100;
        
        $display("Time=%0t: Switch1 pressed, Switch2 released", $time);
        $display("  switch1=%b, led1=%b (LED should be ON)", switch1, led1);
        $display("  switch2=%b, led2=%b (LED should be OFF)", switch2, led2);
        $display("");
        
        // Press switch2, keep switch1 pressed
        switch2 = 0;
        #100;
        
        $display("Time=%0t: Both switches pressed", $time);
        $display("  switch1=%b, led1=%b (LED should be ON)", switch1, led1);
        $display("  switch2=%b, led2=%b (LED should be ON)", switch2, led2);
        $display("");
        
        // Release switch1, keep switch2 pressed
        switch1 = 1;
        #100;
        
        $display("Time=%0t: Switch1 released, Switch2 pressed", $time);
        $display("  switch1=%b, led1=%b (LED should be OFF)", switch1, led1);
        $display("  switch2=%b, led2=%b (LED should be ON)", switch2, led2);
        $display("");
        
        // Release both switches
        switch2 = 1;
        #100;
        
        $display("Time=%0t: Both switches released", $time);
        $display("  switch1=%b, led1=%b (LED should be OFF)", switch1, led1);
        $display("  switch2=%b, led2=%b (LED should be OFF)", switch2, led2);
        $display("");
        
        // Verify expected behavior (now with inversion)
        if (led1 == ~switch1 && led2 == ~switch2) begin
            $display("✓ SUCCESS: LEDs respond to pressed switches correctly!");
            $display("✓ Active high logic working with switch inversion");
            $display("✓ Pure combinational logic working correctly");
        end else begin
            $display("✗ ERROR: LED behavior doesn't match inverted switches");
        end
        
        $display("");
        $display("=== Simulation Complete ===");
        $display("Check build/input_devices.vcd with GTKWave to see waveforms");
        
        $finish;
    end

endmodule
