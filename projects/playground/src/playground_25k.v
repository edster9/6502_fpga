module playground (
    input clk,
    input key,
    input [7:0] switches,    // 8 switches from PMOD1
    output [7:0] leds        // 8 LEDs to PMOD2
);

// Simple direct connection: each switch controls its corresponding LED
assign leds = switches;

endmodule