//===========================================================================
// $Id: synchronizer_flop.v,v 1.4 2001-09-03 13:18:30 bbeaver Exp $
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// synchronizer_flop                                            ////
////                                                              ////
//// This file is part of the general opencores effort.           ////
//// <http://www.opencores.org/cores/misc/>                       ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
//// Make a rising-edge triggered flop with async reset with a    ////
////   distinguished name so that it can be replaced with a flop  ////
////   which does not make X's during simulation.                 ////
////                                                              ////
//// This flop should be used instead of a regular flop for ALL   ////
////   cross-clock-domain flops.  Manually instantiating this     ////
////   flop for all signals which must NEVER go to 1'bX during    ////
////   simulation will make it possible for the user to           ////
////   substitute a simulation model which does NOT have setup    ////
////   and hold checks.                                           ////
////                                                              ////
//// If a target device library has a component which is          ////
////   especially well suited to perform this function, it should ////
////   be instantiated by name in this file.  Otherwise, the      ////
////   behaviorial version of this module will be used.           ////
////                                                              ////
//// To Do:                                                       ////
//// Nothing                                                      ////
////                                                              ////
//// Author(s):                                                   ////
//// - anynomous                                                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2001/09/03 11:16:00  Blue Beaver
// no message
//
// Revision 1.1.1.1  2001/09/03 10:24:58  bbeaver
// no message
//
// Revision 1.1  2001/09/02 11:32:03  Blue Beaver
// no message
//
//

`timescale 1ns/1ps

// If the vendor has a flop which is particularly good at settling out of
//   metastability, it should be used here.
module synchronizer_flop (
  data_in, clk_out, sync_data_out, async_reset
);
  input   data_in;
  input   clk_out;
  output  sync_data_out;
  input   async_reset;

  reg     sync_data_out;

  always @(posedge clk_out or posedge async_reset)
  begin
    if (async_reset == 1'b1)
    begin
      sync_data_out <= 1'b0;
    end
    else
    begin
// In gate-level simulation, must only go to 1'bX if the input is 1'bX or 1'bZ.
// This should NEVER go to 1'bX due to setup or hold violations.
      sync_data_out <= data_in;
    end
  end
endmodule

