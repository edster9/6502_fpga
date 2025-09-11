// TMDS rPLL - PLL for generating TMDS serial clock
// Based on Gowin FPGA PLL primitive for Tang Nano 20K
// Generates 5x pixel clock for TMDS serialization

module TMDS_rPLL (
    input  wire clkin,   // 27MHz input clock
    output wire clkout,  // 5x pixel clock output (742.5MHz for 720p)
    output wire lock     // PLL lock indicator
);

    // For 720p @ 60Hz:
    // Pixel clock = 74.25MHz
    // TMDS clock = 5 * 74.25MHz = 371.25MHz
    // But we'll use a simpler configuration for now
    
    // Use Gowin rPLL primitive
    rPLL #(
        .FCLKIN("27"),          // Input frequency in MHz
        .DYN_IDIV_SEL("false"), // Dynamic input divider disable
        .IDIV_SEL(0),           // Input divider = 1 (27MHz/1 = 27MHz)
        .DYN_FBDIV_SEL("false"),// Dynamic feedback divider disable  
        .FBDIV_SEL(13),         // Feedback divider = 14 (27MHz * 14 = 378MHz)
        .DYN_ODIV_SEL("false"), // Dynamic output divider disable
        .ODIV_SEL(2),           // Output divider = 4 (378MHz/4 = 94.5MHz)
        .PSDA_SEL("0000"),      // Phase shift
        .DYN_DA_EN("false"),    // Dynamic phase shift disable
        .DUTYDA_SEL("1000"),    // Duty cycle adjustment
        .CLKOUT_FT_DIR(1'b1),   // Fine tuning direction
        .CLKOUTP_FT_DIR(1'b1),  // Fine tuning direction positive 
        .CLKOUT_DLY_STEP(0),    // Delay step
        .CLKOUTP_DLY_STEP(0),   // Delay step positive
        .CLKFB_SEL("internal"), // Internal feedback
        .CLKOUTD3_SRC("CLKOUT"), // Clock output D3 source
        .CLKOUTD_BYPASS("false"), // Bypass mode disable
        .CLKOUTD_SRC("CLKOUT"), // Clock output D source
        .DYN_SDIV_SEL(2)        // Dynamic secondary divider
    ) pll_inst (
        .CLKOUT(clkout),        // Main output clock
        .LOCK(lock),            // Lock signal
        .CLKOUTP(),             // Positive phase output (unused)
        .CLKOUTD(),             // Divided output (unused)
        .CLKOUTD3(),            // Divided by 3 output (unused)
        .RESET(1'b0),           // Reset input (tied low)
        .RESET_P(1'b0),         // Positive reset (tied low)
        .CLKIN(clkin),          // Input clock
        .CLKFB(1'b0),           // Feedback clock (internal)
        .FBDSEL(6'b0),          // Feedback divider select (unused in static mode)
        .IDSEL(6'b0),           // Input divider select (unused in static mode)
        .ODSEL(6'b0),           // Output divider select (unused in static mode)
        .PSDA(4'b0),            // Phase shift (unused in static mode)
        .DUTYDA(4'b0),          // Duty adjustment (unused in static mode)
        .FDLY(4'b0)             // Fine delay (unused)
    );

endmodule
