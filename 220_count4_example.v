//------------------------------------------------------------------------
// Copyright (c) 1997 Altera Corporation, all right reserved
//
// This Verilog file may be copied and/or distributed at no cost as long as
// this copyright notice is retained.
//
//----------------------------------------------------------------
// Four-bit Loadable Up-Down Counter with synchronous set, load and clear
//----------------------------------------------------------------
// Version 1.0   Date 07/09/97
//----------------------------------------------------------------
//

`include "210model.v"
module count4 (q, 
        data, clock,
        clk_en, cnt_en, updown,
        sset, sclr, sload) ;

  parameter lpm_width    = 4 ;

  output [lpm_width-1:0] q ;
  input  [lpm_width-1:0] data ;
  input  clock, clk_en, cnt_en, updown ;
  input  sset, sclr, sload ;


  lpm_counter U1 (.q(q), 
        .data(data), .clock(clock),
        .clk_en(clk_en), .cnt_en(cnt_en), .updown(updown),
        .sset(sset), .sclr(sclr), .sload(sload)) ;

    defparam U1.lpm_width=4;

endmodule
