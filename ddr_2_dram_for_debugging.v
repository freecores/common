//////////////////////////////////////////////////////////////////////
////                                                              ////
//// ddr_2_dram #(num_addr_bits, num_col_bits,                    ////
////              num_data_bits, num_words_in_test_memory)        ////
////                                                              ////
//// This file is part of the general opencores effort.           ////
//// <http://www.opencores.org/cores/misc/>                       ////
////                                                              ////
//// Module Description:                                          ////
////   A fake DDR DRAM with a small amount of memory.  Useful in  ////
////   getting a DDR DRAM controller working.                     ////
////                                                              ////
//// The DDR DRAM uses a tricky clocking scheme.  Unfortunately,  ////
////   this will require a tricky controller.                     ////
////                                                              ////
//// The CLK_P and CLK_N signals provide a time-base for the      ////
////   external IO pins on the DRAM, and may or may not be used   ////
////   as a timebase for internal DRAM activity.                  ////
////                                                              ////
//// The DDR DRAM transfers data on both edges of the CLK_*.      ////
////   However, in order to make the design insensitive to layout ////
////   and loading concerns, the data is NOT latched by the CLK_P ////
////   activity.                                                  ////
////                                                              ////
//// Instead the new signal DQS is used as a clock which runs in  ////
////   parallel with, and uses the same loading as, the Data      ////
////   wires DQ.                                                  ////
////                                                              ////
//// In the case of writes from a controller to the DDR DRAM, the ////
////   controller is responsible for placing the edges of DQS so  ////
////   that the edges arrive in the MIDDLE of the data valid      ////
////   period at the DRAMs.                                       ////
////                                                              ////
//// The DDR DRAM specs seem to call out that the controller will ////
////   place the DQS transitions between 0.75 and 1.25 of a clock ////
////   period after the rising edge of CLK_* which initiates a    ////
////   write.  The obvious place to put the DQS signal is right   ////
////   at that edge.  This means that the DATA for the write must ////
////   be sent 1/4 clock EARLIER!                                 ////
////                                                              ////
//// In the case of reads from a DDR DRAM to a controller, the    ////
////   DRAM sends out data and data clock (DQ and DQS) with the   ////
////   same timing.  The edges for these signals should be at the ////
////   same time.  The Controller has to internally delay the DQS ////
////   signal by 1/2 of a bit time, and then use the INTERNAL     ////
////   DELAYED DQS signal to latch the DQ wires.                  ////
////                                                              ////
//// The DDR DRAM specs seem to call out that the DRAM will drive ////
////   DQS between -0.75 and +0.75 nSec of the edges of CLK_*.    ////
////   Of course, it will get to the controller some time later   ////
////   than that.                                                 ////
////                                                              ////
//// To provide bad timing, this DRAM model will measure the      ////
////   period of the CLK_P clock (assuming that it is 50% duty    ////
////   cycle).  It will then deliver data from 0.75 nSec AFTER    ////
////   the clock changes till 0.75 nSec BEFORE it changes again.  ////
////   This will prevent the controller from using the CLK_*      ////
////   signal to latch the data.                                  ////
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
// $Id: ddr_2_dram_for_debugging.v,v 1.1 2001-10-28 12:06:55 bbeaver Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2001/10/28 12:12:11  Blue Beaver
// no message
//
// Revision 1.1  2001/10/28 11:15:47  Blue Beaver
// no message
//

`timescale 1ns / 1ps

module ddr_2_dram (
  DQ, DQS,
  DM,
  A, BA,
  RAS_L,
  CAS_L,
  WE_L,
  CS_L,
  CKE,
  CLK_P, CLK_N
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
  input   CLK_P, CLK_N;

// Try to measure the input clock, to correctly apply X's on
//   the data wires near when the outputs change.
// I have to try to make X's BEFORE the next clock edge!

  time    present_rising_time, high_period;
  time    present_falling_time, low_period;
  reg     data_delay1, data_delay2;

  initial
  begin
    present_rising_time = 0;
    present_falling_time = 0;
    high_period = 0;
    low_period = 0;
    data_delay1 = 1'b0;
    data_delay2 = 1'b0;
  end

  always @(CLK_P)
  begin
    if (CLK_P === 1'b1)  // rising edge
    begin
      present_rising_time = $time;
      if ((present_rising_time !== 0) & (present_falling_time !== 0))
      begin
        high_period = present_rising_time - present_falling_time - (2 * 750);
      end
    end
    if (CLK_P === 1'b0)  // falling edge
    begin
      present_falling_time = $time;
      if ((present_rising_time !== 0) & (present_falling_time !== 0))
      begin
        low_period = present_falling_time - present_rising_time - (2 * 750);
      end
    end
  end

// Once the period of the clock is known, start making X's whenever possible
  always @(posedge CLK_P)
  begin
    if (high_period !== 0)
    begin
      #750          data_delay1 = 1'b1;
      #high_period  data_delay2 = 1'b1;
    end
    else
    begin
      data_delay1 = 1'b1;
      data_delay2 = 1'b1;
    end
    if (CLK_N !== 1'b0)
    begin
      $display ("*** %m DDR DRAM needs to have CLK_N transition with CLK_P at time %t", $time);
    end
  end

  always @(negedge CLK_P)
  begin
    if (low_period !== 0)
    begin
      #750         data_delay1 = 1'b0;
      #low_period  data_delay2 = 1'b0;
    end
    else
    begin
      data_delay1 = 1'b0;
      data_delay2 = 1'b0;
    end
    if (CLK_N !== 1'b1)
    begin
      $display ("*** %m DDR DRAM needs to have CLK_N transition with CLK_P at time %t", $time);
    end
  end

  wire    force_x = (data_delay1 == data_delay2);

// DDR DRAMs always capture their command on the RISING EDGE of CLK_P;
// This fake DDR DRAM understands:  Idle, Activate, Read, Write, Automatic Refresh
// This fake DDR DRAM assumes that all Reads and Writes do automatic precharge.
// This fake DDR DRAM understands writes to the control register
// This fake DDR DRAM always does 4-word bursts.  The first word of data
//           is always the legal one.  The next 3 are that first word inverted.
// DDR DRAMs always capture their data on BOTH EDGES of DQS
// DDR DRAMs always output enable the DQS wire to 1'h0 1 clock before
//           they start sending data
// DDR DRAMs will be allowed to have a latency of 2, 2.5, 3, 3.5, 4, 4.5
//           from the read command.



  assign  DQ = force_x ? 8'hX : 8'h0;

// Storage
  reg    [num_data_bits - 1 : 0] bank0 [0 : num_words_in_test_memory - 1];
  reg    [num_data_bits - 1 : 0] bank1 [0 : num_words_in_test_memory - 1];
  reg    [num_data_bits - 1 : 0] bank2 [0 : num_words_in_test_memory - 1];
  reg    [num_data_bits - 1 : 0] bank3 [0 : num_words_in_test_memory - 1];

endmodule

`define TEST_DDR_2_DRAM
`ifdef TEST_DDR_2_DRAM
module test_ddr_2_dram;
  reg  CLK_P, CLK_N;

  initial
  begin
    CLK_P <= 1'b0;
    CLK_N <= 1'b1;
    while (1'b1)
    begin
      #10000 ;
      CLK_P <= ~CLK_P;
      CLK_N <= ~CLK_N;
    end
  end

  initial
  begin
    #100000 $finish;
  end

  wire   [7:0] DQ;
  wire    DQS;
  reg     DM;
  reg    [12:0] A;
  reg    [1:0] BA;
  reg     RAS_L, CAS_L, WE_L, CS_L, CKE;

ddr_2_dram
# ( 13,  // num_addr_bits
    11,  // num_col_bits
     4,  // num_data_bits
    32   // num_words_in_test_memory
  ) ddr_2_dram (
  .DQ                         (DQ[3:0]),
  .DQS                        (DQS),
  .DM                         (DM),
  .A                          (A[12:0]),
  .BA                         (BA[1:0]),
  .RAS_L                      (RAS_L),
  .CAS_L                      (CAS_L),
  .WE_L                       (WE_L),
  .CS_L                       (CS_L),
  .CKE                        (CKE),
  .CLK_P                      (CLK_P),
  .CLK_N                      (CLK_N)
);

endmodule
`endif  // TEST_DDR_2_DRAM
