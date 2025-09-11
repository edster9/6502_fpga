// DVI Transmitter Top Module
// Simplified TMDS encoder and serializer for Tang Nano 20K
// Based on official Tang Nano examples

module DVI_TX_Top (
    input  wire        I_rst_n,        // Reset (active low)
    input  wire        I_serial_clk,   // Serial clock (5x pixel clock)
    input  wire        I_rgb_clk,      // Pixel clock
    input  wire        I_rgb_vs,       // Vertical sync
    input  wire        I_rgb_hs,       // Horizontal sync
    input  wire        I_rgb_de,       // Data enable
    input  wire [7:0]  I_rgb_r,        // Red data
    input  wire [7:0]  I_rgb_g,        // Green data
    input  wire [7:0]  I_rgb_b,        // Blue data
    
    output wire        O_tmds_clk_p,   // TMDS clock positive
    output wire        O_tmds_clk_n,   // TMDS clock negative
    output wire [2:0]  O_tmds_data_p,  // TMDS data positive {r,g,b}
    output wire [2:0]  O_tmds_data_n   // TMDS data negative {r,g,b}
);

    // TMDS encoded data
    wire [9:0] tmds_data_red;
    wire [9:0] tmds_data_green;
    wire [9:0] tmds_data_blue;
    
    // Control signals for TMDS encoding
    wire [1:0] control_red   = 2'b00;
    wire [1:0] control_green = 2'b00;
    wire [1:0] control_blue  = {I_rgb_vs, I_rgb_hs};
    
    // TMDS Encoders for each color channel
    tmds_encoder tmds_enc_red (
        .clk(I_rgb_clk),
        .rst_n(I_rst_n),
        .data_enable(I_rgb_de),
        .data_in(I_rgb_r),
        .control(control_red),
        .tmds_out(tmds_data_red)
    );
    
    tmds_encoder tmds_enc_green (
        .clk(I_rgb_clk),
        .rst_n(I_rst_n),
        .data_enable(I_rgb_de),
        .data_in(I_rgb_g),
        .control(control_green),
        .tmds_out(tmds_data_green)
    );
    
    tmds_encoder tmds_enc_blue (
        .clk(I_rgb_clk),
        .rst_n(I_rst_n),
        .data_enable(I_rgb_de),
        .data_in(I_rgb_b),
        .control(control_blue),
        .tmds_out(tmds_data_blue)
    );
    
    // TMDS Serializers
    tmds_serializer ser_red (
        .clk_serial(I_serial_clk),
        .clk_pixel(I_rgb_clk),
        .rst_n(I_rst_n),
        .tmds_data(tmds_data_red),
        .tmds_out_p(O_tmds_data_p[2]),
        .tmds_out_n(O_tmds_data_n[2])
    );
    
    tmds_serializer ser_green (
        .clk_serial(I_serial_clk),
        .clk_pixel(I_rgb_clk),
        .rst_n(I_rst_n),
        .tmds_data(tmds_data_green),
        .tmds_out_p(O_tmds_data_p[1]),
        .tmds_out_n(O_tmds_data_n[1])
    );
    
    tmds_serializer ser_blue (
        .clk_serial(I_serial_clk),
        .clk_pixel(I_rgb_clk),
        .rst_n(I_rst_n),
        .tmds_data(tmds_data_blue),
        .tmds_out_p(O_tmds_data_p[0]),
        .tmds_out_n(O_tmds_data_n[0])
    );
    
    // Clock serializer
    tmds_clock_serializer clock_ser (
        .clk_serial(I_serial_clk),
        .clk_pixel(I_rgb_clk),
        .rst_n(I_rst_n),
        .tmds_clk_p(O_tmds_clk_p),
        .tmds_clk_n(O_tmds_clk_n)
    );

endmodule

// TMDS Encoder - converts 8-bit data to 10-bit TMDS
module tmds_encoder (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       data_enable,
    input  wire [7:0] data_in,
    input  wire [1:0] control,
    output reg  [9:0] tmds_out
);

    // Simplified TMDS encoding
    // In a full implementation, this would include DC balancing
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tmds_out <= 10'b0;
        end else begin
            if (data_enable) begin
                // Simplified data encoding - just pad with control bits
                tmds_out <= {2'b01, data_in};
            end else begin
                // Control period encoding
                case (control)
                    2'b00: tmds_out <= 10'b1101010100;
                    2'b01: tmds_out <= 10'b0010101011;
                    2'b10: tmds_out <= 10'b0101010100;
                    2'b11: tmds_out <= 10'b1010101011;
                endcase
            end
        end
    end

endmodule

// TMDS Serializer - converts 10-bit parallel to serial
module tmds_serializer (
    input  wire       clk_serial,
    input  wire       clk_pixel,
    input  wire       rst_n,
    input  wire [9:0] tmds_data,
    output wire       tmds_out_p,
    output wire       tmds_out_n
);

    reg [9:0] shift_reg;
    reg [3:0] bit_counter;
    reg       serial_out;
    
    always @(posedge clk_serial or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 10'b0;
            bit_counter <= 4'b0;
            serial_out <= 1'b0;
        end else begin
            if (bit_counter == 4'd0) begin
                // Load new data at pixel clock rate
                shift_reg <= tmds_data;
                bit_counter <= 4'd9;
            end else begin
                bit_counter <= bit_counter - 1'b1;
            end
            
            serial_out <= shift_reg[bit_counter];
        end
    end
    
    // Simple output for testing - no differential buffers
    assign tmds_out_p = serial_out;
    assign tmds_out_n = ~serial_out;

endmodule

// TMDS Clock Serializer 
module tmds_clock_serializer (
    input  wire clk_serial,
    input  wire clk_pixel,
    input  wire rst_n,
    output wire tmds_clk_p,
    output wire tmds_clk_n
);

    // Simple clock forwarding for testing
    assign tmds_clk_p = clk_pixel;
    assign tmds_clk_n = ~clk_pixel;

endmodule
