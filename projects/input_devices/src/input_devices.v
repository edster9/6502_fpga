// Input Devices Learning Module
// Simple switch-to-LED example for Tang Nano 20K
// Direct connection: Switch 1 → LED 1, Switch 2 → LED 2

module input_devices (
    input wire clk,           // 27MHz clock (not used in this simple example)
    input wire switch1,       // Switch 1 (Tang Nano button SW1) 
    input wire switch2,       // Switch 2 (Tang Nano button SW2)
    output wire led1,         // LED 1 (Red LED)
    output wire led2          // LED 2 (Green LED)
);

    // Direct connection - no debouncing, no clocking
    // This is the SIMPLEST possible digital input example
    
    // Tang Nano switches are active LOW (pressed = 0, released = 1)
    // Tang Nano LEDs are active LOW (on = 0, off = 1) 
    // So we need to invert both for intuitive behavior
    
    assign led1 = switch1;    // LED on when switch pressed
    assign led2 = switch2;    // LED on when switch pressed
    
    /* 
    Learning Notes - SIMPLE SWITCH-TO-LED:
    
    1. ASSIGN STATEMENTS: 
       - Continuous assignment (always active)
       - Like connecting wires directly
       - No clock needed for simple logic
    
    2. ACTIVE LOW vs ACTIVE HIGH:
       - Switch pressed = 0V = logic 0 (active low)
       - Switch released = 3.3V = logic 1 (active low)
       - LED on = 0V = logic 0 (active low) 
       - LED off = 3.3V = logic 1 (active low)
    
    3. POLARITY MATCHING:
       - switch1 = 0 (pressed) → led1 = 0 (on) ✓
       - switch1 = 1 (released) → led1 = 1 (off) ✓
       - Perfect match! No inversion needed.
    
    4. NO DEBOUNCING NEEDED:
       - LEDs respond instantly to switch state
       - No edge detection or counting involved
       - Mechanical bounce doesn't matter for this application
    
    5. NO CLOCK NEEDED:
       - Pure combinational logic
       - Propagation delay is nanoseconds
       - Real-time response
    
    Expected Behavior:
    - Press Switch 1 → Red LED turns on immediately
    - Release Switch 1 → Red LED turns off immediately  
    - Press Switch 2 → Green LED turns on immediately
    - Release Switch 2 → Green LED turns off immediately
    - Both switches work independently
    
    This is the foundation for ALL digital input processing!
    */

endmodule
