// make the tang nano 20k with the two onboard switches and two leds
module playground (
    input clk,
    input key,
    input [1:0] switches,    // 2 switches from onboard
    output [1:0] leds        // 2 LEDs to onboard
);

// Simple direct connection: each switch controls its corresponding LED
assign leds = switches;

endmodule