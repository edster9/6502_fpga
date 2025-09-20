// Playground Testbench
// Simple testbench for experimenting and learning

`timescale 1ns / 1ps

module playground_tb;

    // Testbench signals for switch/LED interface
    reg i_Switch_1;
    reg i_Switch_2; 
    reg i_Switch_3;
    reg i_Switch_4;
    wire o_LED_1;
    wire o_LED_2;
    wire o_LED_3;
    wire o_LED_4;
    
    // Instantiate the playground module
    playground uut (
        .i_Switch_1(i_Switch_1),
        .i_Switch_2(i_Switch_2),
        .i_Switch_3(i_Switch_3),
        .i_Switch_4(i_Switch_4),
        .o_LED_1(o_LED_1),
        .o_LED_2(o_LED_2),
        .o_LED_3(o_LED_3),
        .o_LED_4(o_LED_4)
    );
    
    // Test sequence
    initial begin
        // Initialize signals
        i_Switch_1 = 0;
        i_Switch_2 = 0;
        i_Switch_3 = 0;
        i_Switch_4 = 0;
        
        // Test different switch combinations
        #10;
        $display("All switches OFF: LED1=%b LED2=%b LED3=%b LED4=%b", o_LED_1, o_LED_2, o_LED_3, o_LED_4);
        
        // Test switch 1
        i_Switch_1 = 1;
        #10;
        $display("Switch 1 ON: LED1=%b LED2=%b LED3=%b LED4=%b", o_LED_1, o_LED_2, o_LED_3, o_LED_4);
        i_Switch_1 = 0;
        
        // Test switch 2
        i_Switch_2 = 1;
        #10;
        $display("Switch 2 ON: LED1=%b LED2=%b LED3=%b LED4=%b", o_LED_1, o_LED_2, o_LED_3, o_LED_4);
        i_Switch_2 = 0;
        
        // Test all switches
        i_Switch_1 = 1; i_Switch_2 = 1; i_Switch_3 = 1; i_Switch_4 = 1;
        #10;
        $display("All switches ON: LED1=%b LED2=%b LED3=%b LED4=%b", o_LED_1, o_LED_2, o_LED_3, o_LED_4);
        
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("Time: %t, Switches: %b%b%b%b, LEDs: %b%b%b%b", 
                 $time, i_Switch_1, i_Switch_2, i_Switch_3, i_Switch_4,
                 o_LED_1, o_LED_2, o_LED_3, o_LED_4);
    end

endmodule