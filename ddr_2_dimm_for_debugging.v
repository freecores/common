//////////////////////////////////////////////////////////////////////
////                                                              ////
//// ddr_2_dimm                                                   ////
////                                                              ////
//// This file is part of the general opencores effort.           ////
//// <http://www.opencores.org/cores/misc/>                       ////
////                                                              ////
//// Module Description:                                          ////
////   A fake DDR DIMM containing a number of fake DDR DRAMs.     ////
////   Useful in getting a DDR DRAM controller working.           ////
////                                                              ////
//// Author(s):                                                   ////
//// - Anonymous                                                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Anonymous and OPENCORES.ORG               ////
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
// $Id: ddr_2_dimm_for_debugging.v,v 1.2 2001-10-29 13:37:57 bbeaver Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2001/10/29 13:45:02  Blue Beaver
// no message
//
// Revision 1.1  2001/10/28 11:15:47  Blue Beaver
// no message
//

`timescale 1ns / 1ps

module ddr_2_dimm (
  DQ, DQS,
  DM,
  A, BA,
  RAS_L,
  CAS_L,
  WE_L,
  CS_L,
  CKE,
  clk_p, clk_n
);

// Constant Parameters
parameter num_addr_bits = 13;
parameter num_col_bits  = 11;
parameter num_data_bits =  4;
parameter num_words_in_test_memory = 32;

  inout  [num_data_bits - 1 : 0] DQ;
  inout   DQS;
  input   DM;
  input  [num_addr_bits - 1 : 0] A;
  input  [1 : 0] BA;
  input   RAS_L;
  input   CAS_L;
  input   WE_L;
  input   CS_L;
  input   CKE;
  input   clk_p;
  input   clk_n;


// Storage
  reg    [num_data_bits - 1 : 0] bank0 [0 : num_words_in_test_memory - 1];
  reg    [num_data_bits - 1 : 0] bank1 [0 : num_words_in_test_memory - 1];
  reg    [num_data_bits - 1 : 0] bank2 [0 : num_words_in_test_memory - 1];
  reg    [num_data_bits - 1 : 0] bank3 [0 : num_words_in_test_memory - 1];

endmodule
