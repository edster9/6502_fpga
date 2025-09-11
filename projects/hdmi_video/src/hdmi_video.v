// HDMI Video Generation Module
// Simple HDMI/VGA video output for Tang Nano FPGA
// Based on official Tang Nano 20K HDMI examples
// Generates simple test patterns

module hdmi_video (
    input  wire        I_clk,           // 27MHz main clock
    input  wire        I_rst,           // Reset (active high)
    input  wire        I_key,           // Key input to change patterns
    
    // HDMI outputs
    output wire        O_tmds_clk_p,    // TMDS clock positive
    output wire        O_tmds_clk_n,    // TMDS clock negative  
    output wire [2:0]  O_tmds_data_p,   // TMDS data positive {r,g,b}
    output wire [2:0]  O_tmds_data_n,   // TMDS data negative {r,g,b}
    
    // Status outputs
    output wire [4:0]  O_led,           // LED outputs for status
    output wire        running          // Running indicator
);

    // Internal signals
    wire I_rst_n = ~I_rst;
    wire pll_lock;
    wire serial_clk;  // 5x pixel clock for TMDS serialization
    wire pix_clk;     // Pixel clock
    wire hdmi_rst_n;
    
    // Test pattern signals
    wire tp_vs_in;
    wire tp_hs_in;  
    wire tp_de_in;
    wire [7:0] tp_data_r;
    wire [7:0] tp_data_g;
    wire [7:0] tp_data_b;
    
    // Pattern mode control
    reg [1:0] KEY_sync;
    reg [2:0] mode_reg;
    
    // Key debouncing
    always @(posedge pix_clk or negedge hdmi_rst_n) begin
        if (!hdmi_rst_n)    
            KEY_sync <= 2'b00;
        else                 
            KEY_sync <= {KEY_sync[0], I_key};
    end
    
    wire KEY_pressed = KEY_sync[0] & ~KEY_sync[1];
    
    // Pattern mode selection
    always @(posedge pix_clk or negedge hdmi_rst_n) begin
        if (!hdmi_rst_n)      
            mode_reg <= 3'd0;
        else if (KEY_pressed)   
            mode_reg <= mode_reg + 3'd1;
        else                   
            mode_reg <= mode_reg;
    end
    
    // LED status indicator
    reg [31:0] run_cnt;
    always @(posedge I_clk or negedge I_rst_n) begin
        if(!I_rst_n)
            run_cnt <= 32'd0;
        else if(run_cnt >= 32'd27_000_000)  // 1 second at 27MHz
            run_cnt <= 32'd0;
        else
            run_cnt <= run_cnt + 1'b1;
    end
    
    assign running = (run_cnt < 32'd14_000_000) ? 1'b1 : 1'b0;
    assign O_led = {3'b000, mode_reg[1:0]};  // Show current pattern mode
    
    // PLL for generating TMDS clock (5x pixel clock)
    TMDS_rPLL u_tmds_rpll (
        .clkin(I_clk),         // 27MHz input
        .clkout(serial_clk),   // 5x pixel clock output
        .lock(pll_lock)        // PLL lock status
    );
    
    assign hdmi_rst_n = I_rst_n & pll_lock;
    
    // Clock divider to generate pixel clock from serial clock
    CLKDIV u_clkdiv (
        .RESETN(hdmi_rst_n),
        .HCLKIN(serial_clk),   // 5x pixel clock input
        .CLKOUT(pix_clk),      // Pixel clock output
        .CALIB(1'b1)
    );
    defparam u_clkdiv.DIV_MODE = "5";
    defparam u_clkdiv.GSREN = "false";
    
    // Test pattern generator for 720p @ 60Hz
    testpattern testpattern_inst (
        .I_pxl_clk(pix_clk),
        .I_rst_n(hdmi_rst_n),
        .I_mode(mode_reg),
        .I_single_r(8'd255),     // Single color red component
        .I_single_g(8'd0),       // Single color green component  
        .I_single_b(8'd0),       // Single color blue component
        
        // 720p timing parameters
        .I_h_total(12'd1650),    // Horizontal total time
        .I_h_sync(12'd40),       // Horizontal sync time
        .I_h_bporch(12'd220),    // Horizontal back porch
        .I_h_res(12'd1280),      // Horizontal resolution
        .I_v_total(12'd750),     // Vertical total time
        .I_v_sync(12'd5),        // Vertical sync time
        .I_v_bporch(12'd20),     // Vertical back porch
        .I_v_res(12'd720),       // Vertical resolution
        .I_hs_pol(1'b1),         // Horizontal sync polarity (positive)
        .I_vs_pol(1'b1),         // Vertical sync polarity (positive)
        
        // Outputs
        .O_de(tp_de_in),
        .O_hs(tp_hs_in),
        .O_vs(tp_vs_in),
        .O_data_r(tp_data_r),
        .O_data_g(tp_data_g),
        .O_data_b(tp_data_b)
    );
    
    // DVI/HDMI transmitter - using internal signals
    wire tmds_clk_int;
    wire [2:0] tmds_data_int;
    
    DVI_TX_Top DVI_TX_Top_inst (
        .I_rst_n(hdmi_rst_n),
        .I_serial_clk(serial_clk),
        .I_rgb_clk(pix_clk),
        .I_rgb_vs(tp_vs_in),
        .I_rgb_hs(tp_hs_in),
        .I_rgb_de(tp_de_in),
        .I_rgb_r(tp_data_r),
        .I_rgb_g(tp_data_g),
        .I_rgb_b(tp_data_b),
        .O_tmds_clk_p(tmds_clk_int),     // Internal TMDS clock
        .O_tmds_clk_n(),                 // Not used
        .O_tmds_data_p(tmds_data_int),   // Internal TMDS data
        .O_tmds_data_n()                 // Not used
    );
    
    // Direct assignment for testing - will need ELVDS_OBUF for production
    assign O_tmds_clk_p = tmds_clk_int;
    assign O_tmds_clk_n = ~tmds_clk_int;
    assign O_tmds_data_p = tmds_data_int;
    assign O_tmds_data_n = ~tmds_data_int;

endmodule
