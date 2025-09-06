// Pure 6502 CPU Core - No LEDs, No I/O
// Absolute minimal implementation for FPGA testing

module top (
    input wire clk            // 27MHz system clock from Tang Nano 9K
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

endmodule
