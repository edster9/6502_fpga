/////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
/////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217

module UART_RX #(
    parameter integer CLKS_PER_BIT = 217
) (
    input        i_Clock,
    input        i_RX_Serial,
    output       o_RX_DV,
    output [7:0] o_RX_Byte
);

  localparam integer Idle = 3'b000;
  localparam integer RxStartBit = 3'b001;
  localparam integer RxDataBits = 3'b010;
  localparam integer RxStopBit = 3'b011;
  localparam integer Cleanup = 3'b100;

  reg [7:0] r_Clock_Count = 0;
  reg [2:0] r_Bit_Index = 0;  //8 bits total
  reg [7:0] r_RX_Byte = 0;
  reg       r_RX_DV = 0;
  reg [2:0] r_SM_Main = 0;


  // Purpose: Control RX state machine
  always @(posedge i_Clock) begin

    case (r_SM_Main)
      Idle: begin
        r_RX_DV       <= 1'b0;
        r_Clock_Count <= 0;
        r_Bit_Index   <= 0;

        if (i_RX_Serial == 1'b0)  // Start bit detected
          r_SM_Main <= RxStartBit;
        else r_SM_Main <= Idle;
      end

      // Check middle of start bit to make sure it's still low
      RxStartBit: begin
        if (r_Clock_Count == (CLKS_PER_BIT - 1) / 2) begin
          if (i_RX_Serial == 1'b0) begin
            r_Clock_Count <= 0;  // reset counter, found the middle
            r_SM_Main     <= RxDataBits;
          end else r_SM_Main <= Idle;
        end else begin
          r_Clock_Count <= r_Clock_Count + 1;
          r_SM_Main     <= RxStartBit;
        end
      end  // case: RxStartBit


      // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
      RxDataBits: begin
        if (r_Clock_Count < CLKS_PER_BIT - 1) begin
          r_Clock_Count <= r_Clock_Count + 1;
          r_SM_Main     <= RxDataBits;
        end else begin
          r_Clock_Count          <= 0;
          r_RX_Byte[r_Bit_Index] <= i_RX_Serial;

          // Check if we have received all bits
          if (r_Bit_Index < 7) begin
            r_Bit_Index <= r_Bit_Index + 1;
            r_SM_Main   <= RxDataBits;
          end else begin
            r_Bit_Index <= 0;
            r_SM_Main   <= RxStopBit;
          end
        end
      end  // case: RxDataBits


      // Receive Stop bit.  Stop bit = 1
      RxStopBit: begin
        // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
        if (r_Clock_Count < CLKS_PER_BIT - 1) begin
          r_Clock_Count <= r_Clock_Count + 1;
          r_SM_Main     <= RxStopBit;
        end else begin
          r_RX_DV       <= 1'b1;
          r_Clock_Count <= 0;
          r_SM_Main     <= Cleanup;
        end
      end  // case: RxStopBit


      // Stay here 1 clock
      Cleanup: begin
        r_SM_Main <= Idle;
        r_RX_DV   <= 1'b0;
      end


      default: r_SM_Main <= Idle;

    endcase
  end

  assign o_RX_DV   = r_RX_DV;
  assign o_RX_Byte = r_RX_Byte;

endmodule  // UART_RX
