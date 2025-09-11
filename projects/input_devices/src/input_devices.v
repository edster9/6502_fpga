// Input Devices Learning Module - PS/2 Keyboard Interface
// Basic PS/2 signal monitoring and keyboard interface development
// Tang Nano 20K with PS/2 keyboard connection

module input_devices (
    input wire clk,           // 27MHz system clock
    input wire switch1,       // Switch 1 (Tang Nano button SW1) 
    input wire switch2,       // Switch 2 (Tang Nano button SW2)
    input wire ps2_clk,       // PS/2 Clock from keyboard (Green wire)
    input wire ps2_data,      // PS/2 Data from keyboard (White wire)
    output wire led1,         // LED 1 (Red LED)
    output wire led2,         // LED 2 (Green LED)
    output wire ps2_clk_out,  // PS/2 Clock signal for scope monitoring
    output wire ps2_data_out  // PS/2 Data signal for scope monitoring
);

    // Tang Nano built-in switches - preserved for testing
    assign led1 = switch1;   // LED follows switch1 (release = on)
    assign led2 = switch2;   // LED follows switch2 (release = on)
    
    // Clock divider for test signals
    reg [25:0] counter = 0;
    always @(posedge clk) begin
        counter <= counter + 1;
    end
    
    // PS/2 signal monitoring - Back to normal after isolating issue
    // Pin 30 had hardware/routing issues, moved to Pin 31
    assign ps2_clk_out = ps2_clk;      // Pin 27 monitors ps2_clk signal (pin 31)
    assign ps2_data_out = ps2_data;    // Pin 28 monitors ps2_data signal (pin 29)
    
    /* 
    PS/2 KEYBOARD CONNECTION GUIDE:
    
    PS/2 Extension Cable Wire Colors → Tang Nano 20K Connections:
    - White (DATA)  → Pin 25 (ps2_data input)
    - Black (GND)   → GND on Tang Nano
    - Red (VCC)     → 3.3V on Tang Nano  
    - Green (CLOCK) → Pin 26 (ps2_clk input)
    
    Signal Monitoring Outputs for Oscilloscope:
    - ps2_clk_out  → Pin 27 (monitor PS/2 clock)
    - ps2_data_out → Pin 28 (monitor PS/2 data)
    
    Expected PS/2 Signals:
    - Clock: ~10-16 kHz when keys pressed (idle = high)
    - Data: Serial data frames when keys pressed
    - 11-bit frames: Start(0) + 8 data bits + parity + stop(1)
    
    Testing Steps:
    1. Connect PS/2 keyboard and power up
    2. Use scope to monitor pins 27 (clock) and 28 (data)  
    3. Press keys and observe PS/2 protocol signals
    4. Verify clock edges and data transitions
    */

endmodule
