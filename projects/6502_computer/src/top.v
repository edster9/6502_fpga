// Minimal 6502 Computer Top-Level - CPU Only
// No RAM, ROM, or I/O - just the CPU for testing

module top (
    input wire clk,           // 24MHz system clock
    
    // Status LEDs
    output wire led_r,
    output wire led_g,
    output wire led_b,
    
    // Debug pins (optional)
    output wire [15:0] debug_addr,
    output wire [7:0] debug_data_out,
    output wire debug_we
);

    // System reset (for now, just tie low - CPU will start)
    wire reset = 1'b0;
    
    // CPU interface signals
    wire [15:0] cpu_addr;      // CPU address bus
    wire [7:0] cpu_data_in;    // CPU data input
    wire [7:0] cpu_data_out;   // CPU data output
    wire cpu_we;               // CPU write enable
    wire cpu_irq = 1'b0;       // No interrupts for now
    wire cpu_nmi = 1'b0;       // No NMI for now
    wire cpu_rdy = 1'b1;       // Always ready
    
    // Arlet Ottens 6502 CPU Core
    cpu cpu_inst (
        .clk(clk),
        .reset(reset),
        .AB(cpu_addr),
        .DI(cpu_data_in),
        .DO(cpu_data_out),
        .WE(cpu_we),
        .IRQ(cpu_irq),
        .NMI(cpu_nmi),
        .RDY(cpu_rdy)
    );
    
    // Simple memory stub - just return NOP instructions
    // This will make the CPU execute NOP continuously
    assign cpu_data_in = 8'hEA; // NOP instruction
    
    // LED status indicators
    reg [23:0] counter;
    always @(posedge clk) begin
        counter <= counter + 1;
    end
    
    // Show CPU activity on LEDs
    assign led_r = counter[21];     // Slow blink - system running
    assign led_g = cpu_we;          // Green when CPU writes
    assign led_b = |cpu_addr[15:8]; // Blue when CPU accesses high memory
    
    // Debug outputs
    assign debug_addr = cpu_addr;
    assign debug_data_out = cpu_data_out;
    assign debug_we = cpu_we;

endmodule
