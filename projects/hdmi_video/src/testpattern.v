// Test Pattern Generator for HDMI Video
// Based on Tang Nano official examples
// Generates various test patterns for HDMI output

module testpattern (
    input  wire        I_pxl_clk,      // Pixel clock
    input  wire        I_rst_n,        // Reset (active low)
    input  wire [2:0]  I_mode,         // Pattern mode selection
    input  wire [7:0]  I_single_r,     // Single color red
    input  wire [7:0]  I_single_g,     // Single color green  
    input  wire [7:0]  I_single_b,     // Single color blue
    input  wire [11:0] I_h_total,      // Horizontal total time
    input  wire [11:0] I_h_sync,       // Horizontal sync time
    input  wire [11:0] I_h_bporch,     // Horizontal back porch
    input  wire [11:0] I_h_res,        // Horizontal resolution
    input  wire [11:0] I_v_total,      // Vertical total time
    input  wire [11:0] I_v_sync,       // Vertical sync time
    input  wire [11:0] I_v_bporch,     // Vertical back porch
    input  wire [11:0] I_v_res,        // Vertical resolution
    input  wire        I_hs_pol,       // Horizontal sync polarity
    input  wire        I_vs_pol,       // Vertical sync polarity
    
    output wire        O_de,           // Data enable
    output reg         O_hs,           // Horizontal sync
    output reg         O_vs,           // Vertical sync
    output wire [7:0]  O_data_r,       // Red data output
    output wire [7:0]  O_data_g,       // Green data output
    output wire [7:0]  O_data_b        // Blue data output
);

    // Color definitions (BGR format)
    localparam WHITE   = {8'd255, 8'd255, 8'd255};
    localparam YELLOW  = {8'd0,   8'd255, 8'd255};
    localparam CYAN    = {8'd255, 8'd255, 8'd0};
    localparam GREEN   = {8'd0,   8'd255, 8'd0};
    localparam MAGENTA = {8'd255, 8'd0,   8'd255};
    localparam RED     = {8'd0,   8'd0,   8'd255};
    localparam BLUE    = {8'd255, 8'd0,   8'd0};
    localparam BLACK   = {8'd0,   8'd0,   8'd0};

    // Timing counters
    reg [11:0] H_cnt;
    reg [11:0] V_cnt;
    
    // Pipeline delay for outputs (5 clocks)
    localparam N = 5;
    reg [N-1:0] Pout_de_dn;
    reg [N-1:0] Pout_hs_dn;
    reg [N-1:0] Pout_vs_dn;
    
    // Timing generation
    wire Pout_de_w = ((H_cnt >= (I_h_sync + I_h_bporch)) & 
                      (H_cnt <= (I_h_sync + I_h_bporch + I_h_res - 1'b1))) &
                     ((V_cnt >= (I_v_sync + I_v_bporch)) & 
                      (V_cnt <= (I_v_sync + I_v_bporch + I_v_res - 1'b1)));
                      
    wire Pout_hs_w = ~((H_cnt >= 12'd0) & (H_cnt <= (I_h_sync - 1'b1)));
    wire Pout_vs_w = ~((V_cnt >= 12'd0) & (V_cnt <= (I_v_sync - 1'b1)));
    
    // Horizontal counter
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            H_cnt <= 12'd0;
        else if (H_cnt >= (I_h_total - 1'b1))
            H_cnt <= 12'd0;
        else
            H_cnt <= H_cnt + 1'b1;
    end
    
    // Vertical counter
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            V_cnt <= 12'd0;
        else begin
            if ((V_cnt >= (I_v_total - 1'b1)) && (H_cnt >= (I_h_total - 1'b1)))
                V_cnt <= 12'd0;
            else if (H_cnt >= (I_h_total - 1'b1))
                V_cnt <= V_cnt + 1'b1;
            else
                V_cnt <= V_cnt;
        end
    end
    
    // Pipeline registers for timing
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) begin
            Pout_de_dn <= {N{1'b0}};
            Pout_hs_dn <= {N{1'b1}};
            Pout_vs_dn <= {N{1'b1}};
        end else begin
            Pout_de_dn <= {Pout_de_dn[N-2:0], Pout_de_w};
            Pout_hs_dn <= {Pout_hs_dn[N-2:0], Pout_hs_w};
            Pout_vs_dn <= {Pout_vs_dn[N-2:0], Pout_vs_w};
        end
    end
    
    // Output assignments with polarity control
    assign O_de = Pout_de_dn[4];
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) begin
            O_hs <= 1'b1;
            O_vs <= 1'b1;
        end else begin
            O_hs <= I_hs_pol ? ~Pout_hs_dn[3] : Pout_hs_dn[3];
            O_vs <= I_vs_pol ? ~Pout_vs_dn[3] : Pout_vs_dn[3];
        end
    end
    
    // Pattern generation
    // Active area counters for pattern generation
    reg [11:0] De_hcnt;
    reg [11:0] De_vcnt;
    
    wire De_pos = !Pout_de_dn[1] & Pout_de_dn[0];  // DE rising edge
    wire De_neg = Pout_de_dn[1] & !Pout_de_dn[0];  // DE falling edge  
    wire Vs_pos = !Pout_vs_dn[1] & Pout_vs_dn[0];  // VS rising edge
    
    // Horizontal pixel counter within active area
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            De_hcnt <= 12'd0;
        else if (De_pos == 1'b1)
            De_hcnt <= 12'd0;
        else if (Pout_de_dn[1] == 1'b1)
            De_hcnt <= De_hcnt + 1'b1;
        else
            De_hcnt <= De_hcnt;
    end
    
    // Vertical line counter within active area
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            De_vcnt <= 12'd0;
        else if (Vs_pos == 1'b1)
            De_vcnt <= 12'd0;
        else if (De_neg == 1'b1)
            De_vcnt <= De_vcnt + 1'b1;
        else
            De_vcnt <= De_vcnt;
    end
    
    // Color bar pattern
    reg [11:0] Color_trig_num;
    reg        Color_trig;
    reg [3:0]  Color_cnt;
    reg [23:0] Color_bar;
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Color_trig_num <= 12'd0;
        else if (Pout_de_dn[1] == 1'b0)
            Color_trig_num <= I_h_res[11:3];  // Divide by 8 for 8 color bars
        else if ((Color_trig == 1'b1) && (Pout_de_dn[1] == 1'b1))
            Color_trig_num <= Color_trig_num + I_h_res[11:3];
        else
            Color_trig_num <= Color_trig_num;
    end
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Color_trig <= 1'b0;
        else if (De_hcnt == (Color_trig_num - 1'b1))
            Color_trig <= 1'b1;
        else
            Color_trig <= 1'b0;
    end
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Color_cnt <= 3'd0;
        else if (Pout_de_dn[1] == 1'b0)
            Color_cnt <= 3'd0;
        else if ((Color_trig == 1'b1) && (Pout_de_dn[1] == 1'b1))
            Color_cnt <= Color_cnt + 1'b1;
        else
            Color_cnt <= Color_cnt;
    end
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Color_bar <= 24'd0;
        else if (Pout_de_dn[2] == 1'b1)
            case (Color_cnt)
                3'd0: Color_bar <= WHITE;
                3'd1: Color_bar <= YELLOW;
                3'd2: Color_bar <= CYAN;
                3'd3: Color_bar <= GREEN;
                3'd4: Color_bar <= MAGENTA;
                3'd5: Color_bar <= RED;
                3'd6: Color_bar <= BLUE;
                3'd7: Color_bar <= BLACK;
                default: Color_bar <= BLACK;
            endcase
        else
            Color_bar <= BLACK;
    end
    
    // Grid pattern
    reg Net_h_trig;
    reg Net_v_trig;
    reg [23:0] Net_grid;
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Net_h_trig <= 1'b0;
        else if (((De_hcnt[4:0] == 5'd0) || (De_hcnt == (I_h_res - 1'b1))) && 
                 (Pout_de_dn[1] == 1'b1))
            Net_h_trig <= 1'b1;
        else
            Net_h_trig <= 1'b0;
    end
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Net_v_trig <= 1'b0;
        else if (((De_vcnt[4:0] == 5'd0) || (De_vcnt == (I_v_res - 1'b1))) && 
                 (Pout_de_dn[1] == 1'b1))
            Net_v_trig <= 1'b1;
        else
            Net_v_trig <= 1'b0;
    end
    
    wire [1:0] Net_pos = {Net_v_trig, Net_h_trig};
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Net_grid <= 24'd0;
        else if (Pout_de_dn[2] == 1'b1)
            case (Net_pos)
                2'b00: Net_grid <= BLACK;
                2'b01: Net_grid <= WHITE;
                2'b10: Net_grid <= WHITE;
                2'b11: Net_grid <= WHITE;
                default: Net_grid <= BLACK;
            endcase
        else
            Net_grid <= BLACK;
    end
    
    // Gradient pattern
    reg [23:0] Gray;
    reg [23:0] Gray_d1;
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Gray <= 24'd0;
        else
            Gray <= {De_hcnt[7:0], De_hcnt[7:0], De_hcnt[7:0]};
    end
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Gray_d1 <= 24'd0;
        else
            Gray_d1 <= Gray;
    end
    
    // Single color pattern
    wire [23:0] Single_color = {I_single_b, I_single_g, I_single_r};
    
    // Pattern selection
    wire [23:0] Data_sel = (I_mode[2:0] == 3'b000) ? Color_bar    :
                          (I_mode[2:0] == 3'b001) ? Net_grid     :
                          (I_mode[2:0] == 3'b010) ? Gray_d1      :
                          (I_mode[2:0] == 3'b011) ? Single_color :
                          (I_mode[2:0] == 3'b100) ? GREEN        :
                          (I_mode[2:0] == 3'b101) ? RED          :
                          (I_mode[2:0] == 3'b110) ? BLUE         :
                                                     WHITE;
    
    // Output register
    reg [23:0] Data_tmp;
    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n)
            Data_tmp <= 24'd0;
        else
            Data_tmp <= Data_sel;
    end
    
    // RGB output assignment
    assign O_data_r = Data_tmp[7:0];
    assign O_data_g = Data_tmp[15:8];
    assign O_data_b = Data_tmp[23:16];

endmodule
