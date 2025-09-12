// Composite Video Generation Module
// NTSC/PAL composite video output for Tang Nano FPGA
// Starting with VGA timing (640x480@60Hz) for easier debugging

module composite_video (
    input wire clk,          // 27MHz system clock
    input wire reset,        // Reset signal
    output wire hsync,       // Horizontal sync
    output wire vsync,       // Vertical sync
    output wire composite_sync, // Composite sync (hsync XOR vsync for composite video)
    output wire video_active, // Video active region
    // R2R DAC outputs for analog composite video (8-bit)
    output wire dac_bit7,    // MSB of R2R ladder
    output wire dac_bit6,
    output wire dac_bit5,
    output wire dac_bit4,
    output wire dac_bit3,
    output wire dac_bit2,
    output wire dac_bit1,
    output wire dac_bit0     // LSB of R2R ladder
);

    // NTSC Composite Video timing parameters  
    // NTSC: 525 lines, 15.734kHz horizontal, 59.94Hz vertical
    // Standard NTSC timing for better converter compatibility
    localparam H_VISIBLE    = 720;   // NTSC active video width
    localparam H_FRONT      = 16;    // Front porch
    localparam H_SYNC       = 62;    // Sync pulse (4.7us at 13.5MHz)
    localparam H_BACK       = 60;    // Back porch  
    localparam H_TOTAL      = H_VISIBLE + H_FRONT + H_SYNC + H_BACK; // 858
    
    localparam V_VISIBLE    = 480;   // Active video lines
    localparam V_FRONT      = 9;     // Vertical front porch
    localparam V_SYNC       = 6;     // Vertical sync lines
    localparam V_BACK       = 30;    // Vertical back porch
    localparam V_TOTAL      = V_VISIBLE + V_FRONT + V_SYNC + V_BACK; // 525

    // Clock divider to generate NTSC-compatible pixel clock from 27MHz
    // For NTSC timing, we'll divide by 2 to get 13.5MHz pixel clock (standard NTSC)
    reg [1:0] clk_div;
    reg pixel_clk_en;
    
    always @(posedge clk) begin
        if (reset) begin
            clk_div <= 0;
            pixel_clk_en <= 0;
        end else begin
            clk_div <= clk_div + 1;
            pixel_clk_en <= (clk_div == 2'b01); // Divide by 2 for 13.5MHz pixel clock
        end
    end
    
    // Horizontal and vertical counters
    reg [10:0] h_count;
    reg [9:0] v_count;
    
    always @(posedge clk) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else if (pixel_clk_en) begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1) begin
                    v_count <= 0;
                end else begin
                    v_count <= v_count + 1;
                end
            end else begin
                h_count <= h_count + 1;
            end
        end
    end
    
    // Generate sync signals (negative polarity for NTSC)
    assign hsync = ~((h_count >= (H_VISIBLE + H_FRONT)) && 
                     (h_count < (H_VISIBLE + H_FRONT + H_SYNC)));
    assign vsync = ~((v_count >= (V_VISIBLE + V_FRONT)) && 
                     (v_count < (V_VISIBLE + V_FRONT + V_SYNC)));
    
    // Video active region
    assign video_active = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);
    
    // Composite sync generation for composite video
    // Composite sync = ~(hsync OR vsync) for negative sync composite video
    assign composite_sync = ~(hsync | vsync);
    
    // Simple test pattern generator - high contrast bars for composite video
    reg [7:0] pattern_value;
    
    always @(posedge clk) begin
        if (reset) begin
            pattern_value <= 8'h00;
        end else if (video_active && pixel_clk_en) begin
            // Generate high contrast vertical bars (black and white alternating)
            if (h_count[6]) begin
                pattern_value <= 8'hFF; // White
            end else begin
                pattern_value <= 8'h00; // Black
            end
        end else begin
            // Blanking - black level  
            pattern_value <= 8'h00;
        end
    end

    // Composite Video Generation - direct pattern to video levels
    wire [7:0] luminance = pattern_value;

    // Composite video levels (8-bit for R2R DAC)
    // Standard NTSC composite video levels:
    // - Sync: 0V (0x00) - 0%
    // - Black: 0.3V (0x20) - 12.5% 
    // - White: 1.0V (0xA0) - 62.5%
    localparam [7:0] SYNC_LEVEL  = 8'h00;  // 0V sync level
    localparam [7:0] BLACK_LEVEL = 8'h20;  // Black level (0.3V)
    localparam [7:0] WHITE_LEVEL = 8'hA0;  // White level (1.0V)

    reg [7:0] composite_video;
    
    always @(posedge clk) begin
        if (reset) begin
            composite_video <= BLACK_LEVEL;
        end else begin
            if (~composite_sync) begin
                // Sync pulse - lowest level (active low)
                composite_video <= SYNC_LEVEL;
            end else if (video_active) begin
                // Active video - use pattern value directly scaled to video range
                if (pattern_value > 8'h80) begin
                    composite_video <= WHITE_LEVEL;
                end else begin
                    composite_video <= BLACK_LEVEL;
                end
            end else begin
                // Blanking - black level
                composite_video <= BLACK_LEVEL;
            end
        end
    end

    // R2R DAC output - direct assignment of composite video bits
    assign dac_bit7 = composite_video[7];  // MSB
    assign dac_bit6 = composite_video[6];
    assign dac_bit5 = composite_video[5];
    assign dac_bit4 = composite_video[4];
    assign dac_bit3 = composite_video[3];
    assign dac_bit2 = composite_video[2];
    assign dac_bit1 = composite_video[1];
    assign dac_bit0 = composite_video[0];  // LSB

endmodule
