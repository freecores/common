//////////////////////////////////////////////////////////////////////
////                                                              ////
//// ddr_2_dram #(frequency, latency,                             ////
////              num_addr_bits, num_col_bits,                    ////
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
// $Id: ddr_2_dram_for_debugging.v,v 1.8 2001-11-06 12:33:15 bbeaver Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.10  2001/11/06 12:41:27  Blue Beaver
// no message
//
// Revision 1.9  2001/11/02 11:59:30  Blue Beaver
// no message
//
// Revision 1.8  2001/11/01 13:33:03  Blue Beaver
// no message
//
// Revision 1.7  2001/11/01 12:44:03  Blue Beaver
// no message
//
// Revision 1.6  2001/11/01 11:33:04  Blue Beaver
// no message
//
// Revision 1.5  2001/11/01 09:38:43  Blue Beaver
// no message
//
// Revision 1.4  2001/10/31 12:30:01  Blue Beaver
// no message
//
// Revision 1.3  2001/10/30 12:44:03  Blue Beaver
// no message
//
// Revision 1.2  2001/10/30 08:56:18  Blue Beaver
// no message
//
// Revision 1.1  2001/10/29 13:45:02  Blue Beaver
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
parameter FREQUENCY = 133.0;  // might be 100, 125, 166, any other frequency
parameter LATENCY = 2.0;  // might be 2.0, 2.5, 3.0, 3.5, 4.0
parameter NUM_ADDR_BITS = 13;
parameter NUM_COL_BITS  = 11;
parameter NUM_DATA_BITS =  4;
parameter NUM_WORDS_IN_TEST_MEMORY = 32;
parameter ENABLE_TIMING_CHECKS = 1;

  inout  [NUM_DATA_BITS - 1 : 0] DQ;
  inout   DQS;
  input   DM;
  input  [NUM_ADDR_BITS - 1 : 0] A;
  input  [1 : 0] BA;
  input   RAS_L;
  input   CAS_L;
  input   WE_L;
  input   CS_L;
  input   CKE;
  input   CLK_P, CLK_N;

// These signals can be accessed by upper scopes to detect chip-to-chip OE conflicts.
  wire    DEBUG_DQ_OE, DEBUG_DQS_OE;

// Try to measure the input clock, to correctly apply X's on
//   the data wires near when the outputs change.
// I have to try to make X's BEFORE the next clock edge!
// This measurement is irrespective of the frequency parameter,
//   which is used only to set the number of cycles between events.

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
    begin  // Make X's after rising edge, and before falling edge
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
    begin  // Make X's after falling edge, and before rising edge
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

// Watch for cases where both banks are driving the Data bus at once.
// Normally, the second read would terminate the first read.  This
//   module, since it is only for debugging, only understands complete
//   4-word burst transfers.

  wire   [NUM_DATA_BITS - 1 : 0] DQ_E_out_0;
  wire   [NUM_DATA_BITS - 1 : 0] DQ_O_out_0;
  wire    DQ_E_oe_0, DQS_E_out_0, DQS_E_oe_0, Timing_Error_0;
  wire    DQ_O_oe_0, DQS_O_out_0, DQS_O_oe_0;

  wire   [NUM_DATA_BITS - 1 : 0] DQ_E_out_1;
  wire   [NUM_DATA_BITS - 1 : 0] DQ_O_out_1;
  wire    DQ_E_oe_1, DQS_E_out_1, DQS_E_oe_1, Timing_Error_1;
  wire    DQ_O_oe_1, DQS_O_out_1, DQS_O_oe_1;

  wire   [NUM_DATA_BITS - 1 : 0] DQ_E_out_2;
  wire   [NUM_DATA_BITS - 1 : 0] DQ_O_out_2;
  wire    DQ_E_oe_2, DQS_E_out_2, DQS_E_oe_2, Timing_Error_2;
  wire    DQ_O_oe_2, DQS_O_out_2, DQS_O_oe_2;

  wire   [NUM_DATA_BITS - 1 : 0] DQ_E_out_3;
  wire   [NUM_DATA_BITS - 1 : 0] DQ_O_out_3;
  wire    DQ_E_oe_3, DQS_E_out_3, DQS_E_oe_3, Timing_Error_3;
  wire    DQ_O_oe_3, DQS_O_out_3, DQS_O_oe_3;

  always @(    DQ_E_oe_0   or DQ_E_oe_1   or DQ_E_oe_2   or DQ_E_oe_3
            or DQS_E_out_0 or DQS_E_out_1 or DQS_E_out_2 or DQS_E_out_3
            or DQS_E_oe_0  or DQS_E_oe_1  or DQS_E_oe_2  or DQS_E_oe_3
            or DQ_O_oe_0   or DQ_O_oe_1   or DQ_O_oe_2   or DQ_O_oe_3
            or DQS_O_out_0 or DQS_O_out_1 or DQS_O_out_2 or DQS_O_out_3
            or DQS_O_oe_0  or DQS_O_oe_1  or DQS_O_oe_2  or DQS_O_oe_3 )

  begin
    if (   (DQ_E_oe_0 & DQ_E_oe_1) | (DQ_E_oe_0 & DQ_E_oe_2) | (DQ_E_oe_0 & DQ_E_oe_3)
         | (DQ_E_oe_1 & DQ_E_oe_2) | (DQ_E_oe_1 & DQ_E_oe_3) | (DQ_E_oe_2 & DQ_E_oe_3)
         | (DQ_O_oe_0 & DQ_O_oe_1) | (DQ_O_oe_0 & DQ_O_oe_2) | (DQ_O_oe_0 & DQ_O_oe_3)
         | (DQ_O_oe_1 & DQ_O_oe_2) | (DQ_O_oe_1 & DQ_O_oe_3) | (DQ_O_oe_2 & DQ_O_oe_3) )

    begin
      $display ("*** %m DDR DRAM has multiple banks driving DQ at the same time at %x %t",
                    {DQ_E_oe_3, DQ_O_oe_3, DQ_E_oe_2, DQ_O_oe_2, DQ_E_oe_1, DQ_O_oe_1, DQ_E_oe_0, DQ_O_oe_0}, $time);
    end
    if (   ((DQS_E_oe_0 & DQS_E_oe_1) & ((DQS_E_out_0 != 1'b0) | (DQS_E_out_1 != 1'b0)))
         | ((DQS_E_oe_0 & DQS_E_oe_2) & ((DQS_E_out_0 != 1'b0) | (DQS_E_out_2 != 1'b0)))
         | ((DQS_E_oe_0 & DQS_E_oe_3) & ((DQS_E_out_0 != 1'b0) | (DQS_E_out_3 != 1'b0)))
         | ((DQS_E_oe_1 & DQS_E_oe_2) & ((DQS_E_out_1 != 1'b0) | (DQS_E_out_2 != 1'b0)))
         | ((DQS_E_oe_1 & DQS_E_oe_3) & ((DQS_E_out_1 != 1'b0) | (DQS_E_out_3 != 1'b0)))
         | ((DQS_E_oe_2 & DQS_E_oe_3) & ((DQS_E_out_2 != 1'b0) | (DQS_E_out_3 != 1'b0))) )
    begin
      $display ("*** %m DDR DRAM Even has multiple banks driving DQS at the same time at %x %x %t",
                    {DQS_E_oe_3, DQS_E_oe_2, DQS_E_oe_1, DQS_E_oe_0},
                    {DQS_E_out_3, DQS_E_out_2, DQS_E_out_1, DQS_E_out_0}, $time);
    end
    if (   ((DQS_O_oe_0 & DQS_O_oe_1) & ((DQS_O_out_0 != 1'b0) | (DQS_O_out_1 != 1'b0)))
         | ((DQS_O_oe_0 & DQS_O_oe_2) & ((DQS_O_out_0 != 1'b0) | (DQS_O_out_2 != 1'b0)))
         | ((DQS_O_oe_0 & DQS_O_oe_3) & ((DQS_O_out_0 != 1'b0) | (DQS_O_out_3 != 1'b0)))
         | ((DQS_O_oe_1 & DQS_O_oe_2) & ((DQS_O_out_1 != 1'b0) | (DQS_O_out_2 != 1'b0)))
         | ((DQS_O_oe_1 & DQS_O_oe_3) & ((DQS_O_out_1 != 1'b0) | (DQS_O_out_3 != 1'b0)))
         | ((DQS_O_oe_2 & DQS_O_oe_3) & ((DQS_O_out_2 != 1'b0) | (DQS_O_out_3 != 1'b0))) )
    begin
      $display ("*** %m DDR DRAM Odd has multiple banks driving DQS at the same time at %x %x %t",
                    {DQS_O_oe_3, DQS_O_oe_2, DQS_O_oe_1, DQS_O_oe_0},
                    {DQS_O_out_3, DQS_O_out_2, DQS_O_out_1, DQS_O_out_0}, $time);
    end
  end

  assign  DEBUG_DQ_OE =  DQ_E_oe_0  | DQ_E_oe_1  | DQ_E_oe_2  | DQ_E_oe_3
                      |  DQ_O_oe_0  | DQ_O_oe_1  | DQ_O_oe_2  | DQ_O_oe_3;
  assign  DEBUG_DQS_OE = DQS_E_oe_0 | DQS_E_oe_1 | DQS_E_oe_2 | DQS_E_oe_3
                       | DQS_O_oe_0 | DQS_O_oe_1 | DQS_O_oe_2 | DQS_O_oe_3;

// The top-level code here is responsible for delaying the data as needed
//   to meet the LATENCY requirement.

//    LATENCY,
//parameter LATENCY = 2.0;  // might be 2.0, 2.5, 3.0, 3.5, 4.0

ddr_2_dram_single_bank
# ( FREQUENCY,
    LATENCY,
    NUM_ADDR_BITS,
    NUM_COL_BITS,
    NUM_DATA_BITS,
    NUM_WORDS_IN_TEST_MEMORY,
    1  // enable_timing_checks
  ) ddr_2_dram_single_bank_0 (
  .DQ                         (DQ[NUM_DATA_BITS - 1 : 0]),
  .DQS                        (DQS),
  .DQ_E_out                   (DQ_E_out_0[NUM_DATA_BITS - 1 : 0]),
  .DQ_O_out                   (DQ_O_out_0[NUM_DATA_BITS - 1 : 0]),
  .DQ_E_oe                    (DQ_E_oe_0),
  .DQ_O_oe                    (DQ_O_oe_0),
  .DQS_E_out                  (DQS_E_out_0),
  .DQS_O_out                  (DQS_O_out_0),
  .DQS_E_oe                   (DQS_E_oe_0),
  .DQS_O_oe                   (DQS_O_oe_0),
  .Timing_Error               (Timing_Error_0),
  .DM                         (DM),
  .A                          (A[12:0]),
  .BA                         (BA[1:0]),
  .RAS_L                      (RAS_L),
  .CAS_L                      (CAS_L),
  .WE_L                       (WE_L),
  .CS_L                       (CS_L),
  .CKE                        (CKE),
  .CLK_P                      (CLK_P),
  .CLK_N                      (CLK_N),
  .bank_num                   (2'b00)
);

ddr_2_dram_single_bank
# ( FREQUENCY,
    LATENCY,
    NUM_ADDR_BITS,
    NUM_COL_BITS,
    NUM_DATA_BITS,
    NUM_WORDS_IN_TEST_MEMORY,
    0  // enable_timing_checks
  ) ddr_2_dram_single_bank_1 (
  .DQ                         (DQ[NUM_DATA_BITS - 1 : 0]),
  .DQS                        (DQS),
  .DQ_E_out                   (DQ_E_out_1[NUM_DATA_BITS - 1 : 0]),
  .DQ_O_out                   (DQ_O_out_1[NUM_DATA_BITS - 1 : 0]),
  .DQ_E_oe                    (DQ_E_oe_1),
  .DQ_O_oe                    (DQ_O_oe_1),
  .DQS_E_out                  (DQS_E_out_1),
  .DQS_O_out                  (DQS_O_out_1),
  .DQS_E_oe                   (DQS_E_oe_1),
  .DQS_O_oe                   (DQS_O_oe_1),
  .Timing_Error               (Timing_Error_1),
  .DM                         (DM),
  .A                          (A[12:0]),
  .BA                         (BA[1:0]),
  .RAS_L                      (RAS_L),
  .CAS_L                      (CAS_L),
  .WE_L                       (WE_L),
  .CS_L                       (CS_L),
  .CKE                        (CKE),
  .CLK_P                      (CLK_P),
  .CLK_N                      (CLK_N),
  .bank_num                   (2'b01)
);

ddr_2_dram_single_bank
# ( FREQUENCY,
    LATENCY,
    NUM_ADDR_BITS,
    NUM_COL_BITS,
    NUM_DATA_BITS,
    NUM_WORDS_IN_TEST_MEMORY,
    0  // enable_timing_checks
  ) ddr_2_dram_single_bank_2 (
  .DQ                         (DQ[NUM_DATA_BITS - 1 : 0]),
  .DQS                        (DQS),
  .DQ_E_out                   (DQ_E_out_2[NUM_DATA_BITS - 1 : 0]),
  .DQ_O_out                   (DQ_O_out_2[NUM_DATA_BITS - 1 : 0]),
  .DQ_E_oe                    (DQ_E_oe_2),
  .DQ_O_oe                    (DQ_O_oe_2),
  .DQS_E_out                  (DQS_E_out_2),
  .DQS_O_out                  (DQS_O_out_2),
  .DQS_E_oe                   (DQS_E_oe_2),
  .DQS_O_oe                   (DQS_O_oe_2),
  .Timing_Error               (Timing_Error_2),
  .DM                         (DM),
  .A                          (A[12:0]),
  .BA                         (BA[1:0]),
  .RAS_L                      (RAS_L),
  .CAS_L                      (CAS_L),
  .WE_L                       (WE_L),
  .CS_L                       (CS_L),
  .CKE                        (CKE),
  .CLK_P                      (CLK_P),
  .CLK_N                      (CLK_N),
  .bank_num                   (2'b10)
);

ddr_2_dram_single_bank
# ( FREQUENCY,
    LATENCY,
    NUM_ADDR_BITS,
    NUM_COL_BITS,
    NUM_DATA_BITS,
    NUM_WORDS_IN_TEST_MEMORY,
    0  // enable_timing_checks
  ) ddr_2_dram_single_bank_3 (
  .DQ                         (DQ[NUM_DATA_BITS - 1 : 0]),
  .DQS                        (DQS),
  .DQ_E_out                   (DQ_E_out_3[NUM_DATA_BITS - 1 : 0]),
  .DQ_O_out                   (DQ_O_out_3[NUM_DATA_BITS - 1 : 0]),
  .DQ_E_oe                    (DQ_E_oe_3),
  .DQ_O_oe                    (DQ_O_oe_3),
  .DQS_E_out                  (DQS_E_out_3),
  .DQS_O_out                  (DQS_O_out_3),
  .DQS_E_oe                   (DQS_E_oe_3),
  .DQS_O_oe                   (DQS_O_oe_3),
  .Timing_Error               (Timing_Error_3),
  .DM                         (DM),
  .A                          (A[12:0]),
  .BA                         (BA[1:0]),
  .RAS_L                      (RAS_L),
  .CAS_L                      (CAS_L),
  .WE_L                       (WE_L),
  .CS_L                       (CS_L),
  .CKE                        (CKE),
  .CLK_P                      (CLK_P),
  .CLK_N                      (CLK_N),
  .bank_num                   (2'b11)
);

endmodule

module ddr_2_dram_single_bank (
  DQ, DQS,
  DQ_E_out, DQ_O_out, DQ_E_oe, DQ_O_oe,
  DQS_E_out, DQS_O_out, DQS_E_oe, DQS_O_oe,
  Timing_Error,
  DM,
  A, BA,
  RAS_L,
  CAS_L,
  WE_L,
  CS_L,
  CKE,
  CLK_P, CLK_N,
  bank_num
);

// Constant Parameters
parameter FREQUENCY = 133.0;  // might be 100, 125, 166, any other frequency
parameter LATENCY = 2.0;  // might be 2.0, 2.5, 3.0, 3.5, 4.0, 4.5
parameter NUM_ADDR_BITS = 13;
parameter NUM_COL_BITS  = 12;
parameter NUM_DATA_BITS =  4;
parameter NUM_WORDS_IN_TEST_MEMORY = 32;
parameter ENABLE_TIMING_CHECKS = 1;

  input  [NUM_DATA_BITS - 1 : 0] DQ;
  input   DQS;
  output [NUM_DATA_BITS - 1 : 0] DQ_E_out;
  output [NUM_DATA_BITS - 1 : 0] DQ_O_out;
  output  DQ_E_oe, DQ_O_oe;
  output  DQS_E_out, DQS_O_out, DQS_E_oe, DQS_O_oe;
  output  Timing_Error;
  input   DM;
  input  [NUM_ADDR_BITS - 1 : 0] A;
  input  [1 : 0] BA;
  input   RAS_L;
  input   CAS_L;
  input   WE_L;
  input   CS_L;
  input   CKE;
  input   CLK_P, CLK_N;
  input  [1:0] bank_num;

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

// DDR DRAM commands are made by using the following sighals:
//   {CKE, CS_L, RAS_L, CAS_L, WS_L}
//     0    X     X      X     X      power-down
//     1    1     X      X     X      NOOP
//     1    0     1      1     1      NOOP
//     1    0     0      1     1      ACTIVATE
//     1    0     1      0     1      READ      (A10)
//     1    0     1      0     0      WRITE     (A10)
//     1    0     0      1     0      PRECHARGE (A10)
//     1    0     0      0     1      AUTO REFRESH
//     1    0     0      0     0      LOAD MODE REGISTER
//     1    0     1      1     0      not used?

parameter NOOP           = 5'h17;
parameter LOAD_MODE      = 5'h10;
parameter ACTIVATE_BANK  = 5'h13;
parameter READ_BANK      = 5'h15;
parameter WRITE_BANK     = 5'h14;
parameter PRECHARGE_BANK = 5'h12;
parameter REFRESH_BANK   = 5'h11;

  wire   [4:0] control_wires = {CKE, CS_L, RAS_L, CAS_L, WE_L};

// This simple-minded DRAM assumes that all transactions are valid.
// Therefore, it always captures RAS and CAS address information, even
//   if there is an obvious protocol violation.

  reg    [NUM_ADDR_BITS - 1 : 0] Captured_RAS_Address;
  reg    [1:0] Captured_RAS_Bank_Selects;

  reg    [NUM_ADDR_BITS - 1 : 0] Captured_CAS_Address;
  reg    [1:0] Captured_CAS_Bank_Selects;

  reg     RAS_Address_Valid;
  reg     Full_Address_Valid;
  reg     DRAM_Read_Requested;

// synopsys translate_off
  initial
  begin  // only for debug
    RAS_Address_Valid <= 1'b0;
    Full_Address_Valid <= 1'b0;
  end
// synopsys translate_on

// Capture RAS and CAS address information
  always @(posedge CLK_P)
  begin
    if ((control_wires[4:0] == ACTIVATE_BANK) & (BA[1:0] == bank_num[1:0]))
    begin
      Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0] <= A[NUM_ADDR_BITS - 1 : 0];
      Captured_RAS_Bank_Selects[1:0] <= BA[1 : 0];
      RAS_Address_Valid <= 1'b1;
      Captured_CAS_Address[NUM_ADDR_BITS - 1 : 0] <=
                Captured_CAS_Address[NUM_ADDR_BITS - 1 : 0];
      Captured_CAS_Bank_Selects[1:0] <= Captured_CAS_Bank_Selects[1:0];
      DRAM_Read_Requested <= 1'b0;
      Full_Address_Valid <= 1'b0;
    end
    else if ((control_wires[4:0] == READ_BANK) & (BA[1:0] == bank_num[1:0]))
    begin
      Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0] <=
                Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0];
      Captured_RAS_Bank_Selects[1:0] <= Captured_RAS_Bank_Selects[1:0];
      if (A[10] == 1'b1) // automatic precharge
        RAS_Address_Valid <= 1'b0;
      else
        RAS_Address_Valid <= 1'b1;
      Captured_CAS_Address[NUM_ADDR_BITS - 1 : 0] <= A[NUM_ADDR_BITS - 1 : 0];
      Captured_CAS_Bank_Selects[1:0] <= BA[1 : 0];
      DRAM_Read_Requested <= 1'b1;
      Full_Address_Valid <= 1'b1;
      if (RAS_Address_Valid == 1'b0)
      begin
        $display ("*** %m DRAM accessed for Read without first doing an Activate %t", $time);
      end
    end
    else if ((control_wires[4:0] == WRITE_BANK) & (BA[1:0] == bank_num[1:0]))
    begin
      Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0] <=
                Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0];
      Captured_RAS_Bank_Selects[1:0] <= Captured_RAS_Bank_Selects[1:0];
      if (A[10] == 1'b1) // automatic precharge
        RAS_Address_Valid <= 1'b0;
      else
        RAS_Address_Valid <= 1'b1;
      Captured_CAS_Address[NUM_ADDR_BITS - 1 : 0] <= A[NUM_ADDR_BITS - 1 : 0];
      Captured_CAS_Bank_Selects[1:0] <= BA[1 : 0];
      DRAM_Read_Requested <= 1'b0;
      Full_Address_Valid <= 1'b1;
      if (RAS_Address_Valid == 1'b0)
      begin
        $display ("*** %m DRAM accessed for Write without first doing an Activate %t", $time);
      end
    end
    else if (   (control_wires[4:0] == PRECHARGE_BANK)
              & ((BA[1:0] == bank_num[1:0]) | (A[10] == 1'b1)))
    begin
      Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0] <=
                Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0];
      Captured_RAS_Bank_Selects[1:0] <= Captured_RAS_Bank_Selects[1:0];
      RAS_Address_Valid <= 1'b0;
      Captured_CAS_Address[NUM_ADDR_BITS - 1 : 0] <=
                Captured_CAS_Address[NUM_ADDR_BITS - 1 : 0];
      Captured_CAS_Bank_Selects[1:0] <= Captured_CAS_Bank_Selects[1:0];
      DRAM_Read_Requested <= 1'b0;
      Full_Address_Valid <= 1'b0;
    end
    else  // NOOP, Load Mode Register, Refresh, Unallocated
    begin
      Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0] <=
                Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0];
      Captured_RAS_Bank_Selects[1:0] <= Captured_RAS_Bank_Selects[1:0];
      RAS_Address_Valid <= RAS_Address_Valid;
      Captured_CAS_Address[NUM_ADDR_BITS - 1 : 0] <=
                Captured_CAS_Address[NUM_ADDR_BITS - 1 : 0];
      Captured_CAS_Bank_Selects[1:0] <= Captured_CAS_Bank_Selects[1:0];
      DRAM_Read_Requested <= 1'b0;
      Full_Address_Valid <= 1'b0;
    end
  end

// This debugging DRAM requires that entire 4-word bursts be done.
// At present, this design does not implement DM masking.
// This debugging DRAM captures data using the DQS signals.  It
//   immediately moves the data into the CLK_P positive edge clock domain.

  reg    [NUM_DATA_BITS - 1 : 0] DQS_Captured_Write_Data_Even;
  reg    [NUM_DATA_BITS - 1 : 0] DQS_Captured_Write_Data_Odd;
  reg     DQS_Captured_Write_DM_Even, DQS_Captured_Write_DM_Odd;
  reg    [NUM_DATA_BITS - 1 : 0] Delay_Write_Data_Even;
  reg    [NUM_DATA_BITS - 1 : 0] Sync_Write_Data_Even;
  reg    [NUM_DATA_BITS - 1 : 0] Sync_Write_Data_Odd;
  reg     Delay_Write_DM_Even, Sync_Write_DM_Even, Sync_Write_DM_Odd;

// Capture data on rising edge of DQS
  always @(posedge DQS)
  begin
    DQS_Captured_Write_Data_Even[NUM_DATA_BITS - 1 : 0] <= DQ[NUM_DATA_BITS - 1 : 0];
    DQS_Captured_Write_DM_Even <= DM;
  end

// Delay data captured on rising edge so that it can be captured the NEXT rising edge
  always @(negedge CLK_P)
  begin
    Delay_Write_Data_Even[NUM_DATA_BITS - 1 : 0] <=
                DQS_Captured_Write_Data_Even[NUM_DATA_BITS - 1 : 0];
    Delay_Write_DM_Even <= DQS_Captured_Write_DM_Even;
  end

// Capture data on falling edge of DQS
  always @(negedge DQS)
  begin
    DQS_Captured_Write_Data_Odd[NUM_DATA_BITS - 1 : 0] <= DQ[NUM_DATA_BITS - 1 : 0];
    DQS_Captured_Write_DM_Odd <= DM;
  end

// Capture a data item pair into the positive edge clock domain.
  always @(posedge CLK_P)
  begin
    Sync_Write_Data_Even[NUM_DATA_BITS - 1 : 0] <=
                Delay_Write_Data_Even[NUM_DATA_BITS - 1 : 0];
    Sync_Write_Data_Odd[NUM_DATA_BITS - 1 : 0] <=
                DQS_Captured_Write_Data_Odd[NUM_DATA_BITS - 1 : 0];
    Sync_Write_DM_Even <= Delay_Write_DM_Even;
    Sync_Write_DM_Odd <= DQS_Captured_Write_DM_Odd;
  end

// For Writes, the CAS Address comes in at time T0.
// Data is available on the external DQ wires at time T1 and T2;
// Data is available as Sync_Write_Data at times T2 and T3
// The SRAM can be written as soon as the last data is available,
//   which seems to be at T4.
//
// For Reads, the Address comes in at time T0.
// The DQS signal needs to start being driven to 1'b0 at T1
// The DQ signals need to start being driven with valid data at T2
// Both DQS and DQ need to be valid until the beginning of T4
//
// At first glance, it would seem that the Read Data needs to be
//   grabbed out of the DRAM before, or at the same time, as the
//   data is written into the DRAM.
// Fortunately, the parameter TWTR says that there must be 1 extra
//   clock between a Write and a Read to serve as a Write Recovery
//   time.  Write data is available out of the internal Sync DRAM
//   storage element in plenty of time to get to the bus.

  reg    [NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0] DRAM_Address_T1;
  reg    [NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0] DRAM_Address_T2;
  reg    [NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0] DRAM_Address_T3;
  reg    [1:0] BANK_Address_T1, BANK_Address_T2, BANK_Address_T3;
  reg     DRAM_Read_T1, DRAM_Read_T2, DRAM_Read_T3;
  reg     DRAM_Full_Addr_Valid_T1, DRAM_Full_Addr_Valid_T2, DRAM_Full_Addr_Valid_T3;
  reg    [NUM_DATA_BITS - 1 : 0] Delayed_Sync_Write_Data_Even_T3;
  reg    [NUM_DATA_BITS - 1 : 0] Delayed_Sync_Write_Data_Odd_T3;

// Pipeline delay the Read and Write address so that it stays available
//   all the way up to the time the data is available and the whole
//   lot of it is written to storage.

  always @(posedge CLK_P)
  begin
    DRAM_Address_T1[NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0] <=
                {Captured_RAS_Address[NUM_ADDR_BITS - 1 : 0],
                 Captured_CAS_Address[NUM_COL_BITS - 1 : 11],  // skip address bit 10
                 Captured_CAS_Address[9 : 0]};
    DRAM_Address_T2[NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0] <=
                DRAM_Address_T1[NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0];
    DRAM_Address_T3[NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0] <=
                DRAM_Address_T2[NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0];
    BANK_Address_T1[1:0] <= Captured_CAS_Bank_Selects[1:0];
    BANK_Address_T2[1:0] <= BANK_Address_T1[1:0];
    BANK_Address_T3[1:0] <= BANK_Address_T2[1:0];
    DRAM_Read_T1 <= DRAM_Read_Requested;
    DRAM_Read_T2 <= DRAM_Read_T1;
    DRAM_Read_T3 <= DRAM_Read_T2;
    DRAM_Full_Addr_Valid_T1 <= Full_Address_Valid;
    DRAM_Full_Addr_Valid_T2 <= DRAM_Full_Addr_Valid_T1;
    DRAM_Full_Addr_Valid_T3 <= DRAM_Full_Addr_Valid_T2;
    Delayed_Sync_Write_Data_Even_T3[NUM_DATA_BITS - 1 : 0] <=
                Sync_Write_Data_Even[NUM_DATA_BITS - 1 : 0];
    Delayed_Sync_Write_Data_Odd_T3[NUM_DATA_BITS - 1 : 0] <=
                Sync_Write_Data_Odd[NUM_DATA_BITS - 1 : 0];
  end


  assign  DQ_E_oe = 1'b0;
  assign  DQ_O_oe = 1'b0;
  assign  DQS_E_oe = 1'b0;
  assign  DQS_O_oe = 1'b0;

// Storage

  wire   [(4 * NUM_DATA_BITS) - 1 : 0] write_data =
                {Sync_Write_Data_Odd[NUM_DATA_BITS - 1 : 0],
                 Sync_Write_Data_Even[NUM_DATA_BITS - 1 : 0],
                 Delayed_Sync_Write_Data_Odd_T3[NUM_DATA_BITS - 1 : 0],
                 Delayed_Sync_Write_Data_Even_T3[NUM_DATA_BITS - 1 : 0]};
  wire   [(4 * NUM_DATA_BITS) - 1 : 0] read_data;
                 
sram_for_debugging_sync
# ( NUM_ADDR_BITS + NUM_COL_BITS,
    4 * NUM_DATA_BITS  // NUM_DATA_BITS
  ) storage (
  .data_out                   (read_data[(4 * NUM_DATA_BITS) - 1 : 0]),
  .data_in                    (write_data[(4 * NUM_DATA_BITS) - 1 : 0]),
  .address                    (DRAM_Address_T3[NUM_ADDR_BITS + NUM_COL_BITS - 1 : 0]),
  .read_enable                (DRAM_Full_Addr_Valid_T3 &  DRAM_Read_T3),
  .write_enable               (DRAM_Full_Addr_Valid_T3 & ~DRAM_Read_T3),
  .clk                        (CLK_P)
);

// These are the important DDR DRAM timing specs in nanoseconds:
parameter LOAD_MODE_REGISTER_PERIOD_TMRD   = 15.0;  // stay idle after load mode
parameter ACT_A_TO_ACT_B_TRRD              = 15.0;  // Activate-to-activate minimum time
parameter ACT_TO_READ_OR_WRITE_TRCD        = 20.0;
parameter ACT_TO_PRECHARGE_TRAS            = 40.0;
parameter ACT_TO_REFRESH_TRC               = 65.0;
parameter ACT_A_TO_ACT_A_TRC               = 65.0;  // needed if failover
parameter WRITE_RECOVERY_TO_PRECHARGE_TWR  = 15.0;
parameter PRECHARGE_PERIOD_TRP             = 20.0;
parameter REFRESH_PERIOD_TRFC              = 75.0;

parameter CLOCK_PERIOD = (1.0 / FREQUENCY);

// These timing requirements become CYCLE requirements, depending on the
//   operating frequency.  Note that 133.333 MHz = 7.5 nSec;
// These calculations assume that 133 MHz is the fastest this circuit will run.
// These are calculated by doing (N * 1/period) for N big enough to result in > 85 MHz.
// Each 1/period gives a frequency to test for, and each N gives the cycle count.
// Example:  20 nSec gives N * 50 MHz.  So for N == 2, that gives 100 MHz > 85 MHz.
//           If FREQUENCY > 100 MHz, use N = 2, else use N = 1;
// The cycle count is the number of cycles to HOLD OFF doing the next command.
// p.s. Note I don't know how to take the integer part of something in verilog!

parameter LOAD_MODE_REGISTER_CYCLES          =  (FREQUENCY > 133.334) ? 3 : 2;
parameter ACT_A_TO_ACT_B_CYCLES              =  (FREQUENCY > 133.334) ? 3 : 2;
parameter ACT_TO_READ_OR_WRITE_CYCLES        =  (FREQUENCY > 100.000) ? 3 : 2;
parameter ACT_TO_PRECHARGE_CYCLES            =  (FREQUENCY > 125.000) ? 6
                                             : ((FREQUENCY > 100.000) ? 5 : 4);
// parameter ACK_TO_REFRESH_CYCLES              =  (FREQUENCY > 123.075) ? 9
//                                             : ((FREQUENCY > 107.690) ? 8
//                                             : ((FREQUENCY >  92.300) ? 7 : 6));
parameter ACT_A_TO_ACT_A_CYCLES              =  (FREQUENCY > 123.075) ? 9
                                             : ((FREQUENCY > 107.690) ? 8
                                             : ((FREQUENCY >  92.300) ? 7 : 6));
parameter READ_TO_WRITE_CYCLES               =  (LATENCY > 4.0) ? 5
                                             : ((LATENCY > 3.0) ? 4
                                             : ((LATENCY > 2.0) ? 3 : 2));
parameter WRITE_TO_READ_CYCLES               = 2;
parameter WRITE_RECOVERY_TO_PRECHARGE_CYCLES =  (FREQUENCY > 133.334) ? 3 : 2;
parameter PRECHARGE_CYCLES                   =  (FREQUENCY > 100.000) ? 3 : 2;
parameter REFRESH_CYCLES                     =  (FREQUENCY > 133.334) ? 11
                                             : ((FREQUENCY > 120.000) ? 10
                                             : ((FREQUENCY > 106.667) ? 9
                                             : ((FREQUENCY >  93.330) ? 8 : 7)));

// The DDR-II DRAM has 4 banks.  Each bank can operate independently, with
//   only a few exceptions.
//
// Each bank needs counters to
// 1) prevent refresh too soon after activate
// 2) prevent activate to same bank too soon after activate
// 3) prevent activate to alternate bank too soon after activate
// 4) prevent (or notice) precharge too soon after activate
// 5) count out autorefresh delay

  reg    [3:0] load_mode_delay_counter;
  reg    [3:0] act_a_to_act_b_counter;
  reg    [3:0] act_to_read_or_write_counter;
  reg    [3:0] act_to_precharge_counter;
  reg    [3:0] act_a_to_act_a_counter;  // double use for act_to_refresh and act_a_to_act_a
  reg    [3:0] burst_counter;
  reg    [3:0] read_to_write_counter;
  reg    [3:0] write_to_read_counter;
  reg    [3:0] write_recovery_counter;
  reg    [3:0] precharge_counter;
  reg    [3:0] refresh_counter;

parameter POWER_ON                          = 0;
parameter WRITING_REG                       = 1;
parameter BANK_IDLE                         = 2;
parameter ACTIVATING                        = 3;
parameter WRITING                           = 4;
parameter WRITING_PRECHARGE                 = 5;
parameter READING                           = 6;
parameter READING_PRECHARGE                 = 7;
parameter PRECHARGING                       = 8;
parameter REFRESHING                        = 9;
parameter WAITING_FOR_AUTO_PRECHARGE       = 10;

parameter BANK_STATE_WIDTH = 4;

  reg    [BANK_STATE_WIDTH - 1 : 0] bank_state;
  reg     Timing_Error;

  initial
  begin  // nail state to known at the start of simulation
    bank_state[BANK_STATE_WIDTH - 1 : 0] = POWER_ON;  // nail it to known at the start of simulation
  end

  always @(posedge CLK_P)
  begin
    if (ENABLE_TIMING_CHECKS != 0)
    begin  // if out the entire case statement!
    case (bank_state[BANK_STATE_WIDTH - 1 : 0])
      POWER_ON:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= POWER_ON;
            Timing_Error <= 1'b0;
          end
          else if (control_wires[4:0] == LOAD_MODE)  // no bank involved
          begin
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_REG;
            Timing_Error <= 1'b0;
          end
          else
          begin
            $display ("*** %m DDR DRAM needs to have a LOAD MODE REGISTER before any other command %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= POWER_ON;
            Timing_Error <= 1'b1;
          end
          load_mode_delay_counter[3:0]      <= LOAD_MODE_REGISTER_CYCLES;
          act_a_to_act_b_counter[3:0]       <= 4'h0;
          act_to_read_or_write_counter[3:0] <= 4'h0;
          act_to_precharge_counter[3:0]     <= 4'h0;
          act_a_to_act_a_counter[3:0]       <= 4'h0;
          burst_counter[3:0]                <= 4'h0;
          read_to_write_counter [3:0]       <= 4'h0;
          write_to_read_counter [3:0]       <= 4'h0;
          write_recovery_counter[3:0]       <= 4'h0;
          precharge_counter[3:0]            <= 4'h0;
          refresh_counter[3:0]              <= 4'h0;
        end

      WRITING_REG:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            if (load_mode_delay_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_REG;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
              Timing_Error <= 1'b0;
            end
          end
          else  // nothing else legal until load mode finished
          begin
            if (load_mode_delay_counter[3:0] > 4'h2)  // looping
            begin
              $display ("*** %m DDR DRAM cannot accept any other command while doing a LOAD MODE REGISTER command %t", $time);
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_REG;
              Timing_Error <= 1'b1;
            end
            else
            begin
              $display ("*** %m DDR DRAM cannot accept any other command while doing a LOAD MODE REGISTER command %t", $time);
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
              Timing_Error <= 1'b1;
            end
          end
          load_mode_delay_counter[3:0]      <= (load_mode_delay_counter[3:0] != 4'h0)
                                             ? (load_mode_delay_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_b_counter[3:0]       <= 4'h0;
          act_to_read_or_write_counter[3:0] <= 4'h0;
          act_to_precharge_counter[3:0]     <= 4'h0;
          act_a_to_act_a_counter[3:0]       <= 4'h0;
          burst_counter[3:0]                <= 4'h0;
          read_to_write_counter [3:0]       <= 4'h0;
          write_to_read_counter [3:0]       <= 4'h0;
          write_recovery_counter[3:0]       <= 4'h0;
          precharge_counter[3:0]            <= 4'h0;
          refresh_counter[3:0]              <= 4'h0;
        end

// All interesting work starts here, except for read, write followed by read, write, precharge
      BANK_IDLE:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            Timing_Error <= 1'b0;
            act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
            act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                               ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
            act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                               ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
            act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == LOAD_MODE)  // no bank involved
          begin
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_REG;
            Timing_Error <= 1'b0;
            act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
            act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                               ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
            act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                               ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
            act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              if (act_a_to_act_a_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do an ACT too soon after another ACT to the same bank %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
                Timing_Error <= 1'b1;
                act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                                   ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
                act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                                   ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
                act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                                   ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
                act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                                   ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b0;
                act_a_to_act_b_counter[3:0]       <= ACT_A_TO_ACT_B_CYCLES;
                act_to_read_or_write_counter[3:0] <= ACT_TO_READ_OR_WRITE_CYCLES;
                act_to_precharge_counter[3:0]     <= ACT_TO_PRECHARGE_CYCLES;
                act_a_to_act_a_counter[3:0]       <= ACT_A_TO_ACT_A_CYCLES;
              end
            end
            else  // some other bank
            begin
              if (act_a_to_act_b_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do an ACT too soon after another ACT to the same bank %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
                Timing_Error <= 1'b1;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
                Timing_Error <= 1'b0;
              end
              act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                                 ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
              act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                                 ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
              act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                                 ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
              act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                                 ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
            end
          end
          else if ((control_wires[4:0] == READ_BANK) & (BA[1:0] != bank_num[1:0]))
          begin
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            Timing_Error <= 1'b0;
            act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
            act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                               ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
            act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                               ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
            act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          end
          else if ((control_wires[4:0] == WRITE_BANK) & (BA[1:0] != bank_num[1:0]))
          begin
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            Timing_Error <= 1'b0;
            act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
            act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                               ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
            act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                               ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
            act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)
          begin
            if ((BA[1:0] == bank_num[1:0]) | (A[10] == 1'b1))
            begin
              if (act_to_precharge_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do an PRECHARGE too soon after ACTIVATE %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
                Timing_Error <= 1'b1;
              end
              else  // ignore precharges when in idle state
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
                Timing_Error <= 1'b0;
              end
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
              Timing_Error <= 1'b0;
            end
            act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
            act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                               ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
            act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                               ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
            act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == REFRESH_BANK)  // all already precharged
          begin
            if (act_a_to_act_a_counter[3:0] > 4'h1)
            begin
              $display ("*** %m DDR DRAM cannot do an REFRESH too soon after ACTIVATE %t", $time);
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
              Timing_Error <= 1'b1;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= REFRESHING;
              Timing_Error <= 1'b0;
            end
            act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
            act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                               ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
            act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                               ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
            act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          end
          else
          begin
            $display ("*** %m DDR DRAM can only do Activate, Refresh, Precharge, or Load Mode Register from Idle %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            Timing_Error <= 1'b1;
            act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
            act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                               ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
            act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                               ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
            act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                               ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          end
          load_mode_delay_counter[3:0]      <= LOAD_MODE_REGISTER_CYCLES;
          burst_counter[3:0]                <= 4'h0;
          read_to_write_counter [3:0]       <= 4'h0;
          write_to_read_counter [3:0]       <= 4'h0;
          write_recovery_counter[3:0]       <= (write_recovery_counter[3:0] != 4'h0)
                                             ? (write_recovery_counter[3:0] - 4'h1) : 4'h0;
          precharge_counter[3:0]            <= (precharge_counter[3:0] != 4'h0)
                                             ? (precharge_counter[3:0] - 4'h1) : 4'h0;
          refresh_counter[3:0]              <= REFRESH_CYCLES;
        end

      ACTIVATING:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
            Timing_Error <= 1'b0;
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Activate to a bank which is already Activated %t", $time);
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              Timing_Error <= 1'b1;
            end
            else
            begin
              if (act_a_to_act_b_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do an Activate to a different bank too soon after this bank is Activated %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b1;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b0;
              end
            end
          end
          else if (control_wires[4:0] == READ_BANK)  // no bank involved
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              if (act_to_read_or_write_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM has to wait from Activate to Read %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b1;
              end
              else if (write_to_read_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM has to wait from Write to Read %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b1;
              end
              else
              begin
                if (A[10] == 1'b1)
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
                else
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
                Timing_Error <= 1'b0;
              end
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              Timing_Error <= 1'b0;
            end
          end
          else if (control_wires[4:0] == WRITE_BANK)  // no bank involved
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              if (act_to_read_or_write_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM has to wait from Activate to Write %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b1;
              end
              else if (read_to_write_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM has to wait from Read to Write %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b1;
              end
              else
              begin
                if (A[10] == 1'b1)
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
                else
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;
                Timing_Error <= 1'b0;
              end
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              Timing_Error <= 1'b0;
            end
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)  // only do precharge if this bank is addressed
          begin
            if ((BA[1:0] == bank_num[1:0]) | (A[10] == 1'b1))
            begin
              if (act_to_precharge_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM has to wait from Activate to Precharge %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b1;
              end
              else if (write_recovery_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM has to wait from end of Write to Precharge %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
                Timing_Error <= 1'b1;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
                Timing_Error <= 1'b0;
              end
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              Timing_Error <= 1'b0;
            end
          end
          else
          begin
            $display ("*** %m DDR DRAM can only do Read, Write, or Precharge from Activated %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
            Timing_Error <= 1'b1;
          end
          load_mode_delay_counter[3:0]      <= 4'h0;
          act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
          act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                             ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
          act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                             ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          burst_counter[3:0]                <= 4'h2;
          read_to_write_counter [3:0]       <= (read_to_write_counter[3:0] != 4'h0)
                                             ? (read_to_write_counter[3:0] - 4'h1) : 4'h0;
          write_to_read_counter [3:0]       <= (write_to_read_counter[3:0] != 4'h0)
                                             ? (write_to_read_counter[3:0] - 4'h1) : 4'h0;
          write_recovery_counter[3:0]       <= (write_recovery_counter[3:0] != 4'h0)
                                             ? (write_recovery_counter[3:0] - 4'h1) : 4'h0;
          precharge_counter[3:0]            <= PRECHARGE_CYCLES;
          refresh_counter[3:0]              <= 4'h0;
        end

      WRITING:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              Timing_Error <= 1'b0;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Activate to a bank which is being Written %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              if (act_a_to_act_b_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do an Activate to a different bank too soon after this bank is Activated %t", $time);
                Timing_Error <= 1'b1;
              end
              else
              begin
                Timing_Error <= 1'b0;
              end
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == READ_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do a Read until Write completes plus recovery %t", $time);
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == WRITE_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do a Write to a bank until the previous Write completes %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;  // might want to go to activate!
                Timing_Error <= 1'b1;
                burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                   ? (burst_counter[3:0] - 4'h1) : 4'h0;
              end
              else
              begin
                if (A[10] == 1'b1)
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
                else
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;
                Timing_Error <= 1'b0;
                burst_counter[3:0]                <= 4'h2;
              end
            end
            else  // was to a different bank.  We are done
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              end
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)  // do idles when it is safe to do so
          begin
            if ((BA[1:0] == bank_num[1:0]) | (A[10] == 1'b1))
            begin
              $display ("*** %m DDR DRAM cannot do a Precharge until Write completes plus recovery %t", $time);
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else
          begin
            $display ("*** %m DDR DRAM can only do Read, Write, or Precharge from Write %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING;
            Timing_Error <= 1'b1;
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                              ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          load_mode_delay_counter[3:0]      <= 4'h0;
          act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
          act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                             ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
          act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                             ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          read_to_write_counter [3:0]       <= (read_to_write_counter[3:0] != 4'h0)
                                             ? (read_to_write_counter[3:0] - 4'h1) : 4'h0;
          write_to_read_counter [3:0]       <= WRITE_TO_READ_CYCLES;
          write_recovery_counter[3:0]       <= WRITE_RECOVERY_TO_PRECHARGE_CYCLES + 1;  // to let write finish!
          precharge_counter[3:0]            <= PRECHARGE_CYCLES;
          refresh_counter[3:0]              <= 4'h0;
        end

      WRITING_PRECHARGE:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Activate to a bank which is being Written %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              if (act_a_to_act_b_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do an Activate to a different bank too soon after this bank is Activated %t", $time);
                Timing_Error <= 1'b1;
              end
              else
              begin
                Timing_Error <= 1'b0;
              end
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == READ_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do a Read until Write_precharge completes precharge %t", $time);
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == WRITE_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do a Write until Write_precharge completes precharge %t", $time);
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)  // do idles when it is safe to do so
          begin
            if ((BA[1:0] == bank_num[1:0]) | (A[10] == 1'b1))
            begin
              $display ("*** %m DDR DRAM cannot do a Precharge until Write_precharge completes plus recovery %t", $time);
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            else  // was to a different bank.  We are done
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              end
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else
          begin
            $display ("*** %m DDR DRAM can only wait from Write_precharge %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= WRITING_PRECHARGE;
            Timing_Error <= 1'b1;
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                              ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          load_mode_delay_counter[3:0]      <= 4'h0;
          act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
          act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                             ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
          act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                             ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          read_to_write_counter [3:0]       <= (read_to_write_counter[3:0] != 4'h0)
                                             ? (read_to_write_counter[3:0] - 4'h1) : 4'h0;
          write_to_read_counter [3:0]       <= WRITE_TO_READ_CYCLES;
          write_recovery_counter[3:0]       <= WRITE_RECOVERY_TO_PRECHARGE_CYCLES + 1;  // to let write finish!
          precharge_counter[3:0]            <= PRECHARGE_CYCLES;
          refresh_counter[3:0]              <= 4'h0;
        end

      READING:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              Timing_Error <= 1'b0;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Activate to a bank which is being Read %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              if (act_a_to_act_b_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do an Activate to a different bank too soon after this bank is Activated %t", $time);
                Timing_Error <= 1'b1;
              end
              else
              begin
                Timing_Error <= 1'b0;
              end
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == READ_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do a Read to a bank until the previous Read completes %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
                Timing_Error <= 1'b1;
                burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                   ? (burst_counter[3:0] - 4'h1) : 4'h0;
              end
              else
              begin
                if (A[10] == 1'b1)
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
                else
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
                Timing_Error <= 1'b0;
                burst_counter[3:0]                <= 4'h2;
              end
            end
            else  // was to a different bank.  We are done
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              end
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
          end
          else if (control_wires[4:0] == WRITE_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do a Read until Write completes plus recovery %t", $time);
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            else  // was to a different bank.  We are done
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              end
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)  // do idles when it is safe to do so
          begin
            if ((BA[1:0] == bank_num[1:0]) | (A[10] == 1'b1))
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                $display ("*** %m DDR DRAM cannot do a Precharge to a bank until the previous Read completes %t", $time);
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
                Timing_Error <= 1'b1;
                burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                   ? (burst_counter[3:0] - 4'h1) : 4'h0;
              end
              else
              begin
                if (act_to_precharge_counter[3:0] > 4'h1)
                begin
                  $display ("*** %m DDR DRAM has to wait during READ from Activate to Precharge %t", $time);
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
                  Timing_Error <= 1'b1;
                end
                else
                begin
                  bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
                  Timing_Error <= 1'b0;
                end
              end
            end
            else  // was to a different bank.  We are done
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= ACTIVATING;
              end
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else
          begin
            $display ("*** %m DDR DRAM can only do Read, Write, or Precharge from Read %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING;
            Timing_Error <= 1'b1;
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          load_mode_delay_counter[3:0]      <= (load_mode_delay_counter[3:0] != 4'h0)
                                             ? (load_mode_delay_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
          act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                             ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
          act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                             ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          read_to_write_counter [3:0]       <= READ_TO_WRITE_CYCLES;
          write_to_read_counter [3:0]       <= (write_to_read_counter[3:0] != 4'h0)
                                             ? (write_to_read_counter[3:0] - 4'h1) : 4'h0;
          write_recovery_counter[3:0]       <= (write_recovery_counter[3:0] != 4'h0)
                                             ? (write_recovery_counter[3:0] - 4'h1) : 4'h0;
          precharge_counter[3:0]            <= PRECHARGE_CYCLES;
          refresh_counter[3:0]              <= 4'h0;
        end

      READING_PRECHARGE:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Activate to a bank which is being Read %t", $time);
              Timing_Error <= 1'b1;
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == READ_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do a Read until Read_precharge completes precharge %t", $time);
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == WRITE_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do a Write until Read_precharge completes precharge %t", $time);
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            if (burst_counter[3:0] > 4'h1)
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)  // do idles when it is safe to do so
          begin
            if ((BA[1:0] == bank_num[1:0]) | (A[10] == 1'b1))
            begin
              $display ("*** %m DDR DRAM cannot do a Precharge until Read_precharge completes plus recovery %t", $time);
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            else  // was to a different bank.  We are done
            begin
              if (burst_counter[3:0] > 4'h1)
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
              end
              else
              begin
                bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              end
            end
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          else
          begin
            $display ("*** %m DDR DRAM can only do Read, Write, or Precharge from Read %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= READING_PRECHARGE;
            Timing_Error <= 1'b1;
            burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                               ? (burst_counter[3:0] - 4'h1) : 4'h0;
          end
          load_mode_delay_counter[3:0]      <= (load_mode_delay_counter[3:0] != 4'h0)
                                             ? (load_mode_delay_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
          act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                             ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
          act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                             ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                             ? (burst_counter[3:0] - 4'h1) : 4'h0;
          read_to_write_counter [3:0]       <= READ_TO_WRITE_CYCLES;
          write_to_read_counter [3:0]       <= (write_to_read_counter[3:0] != 4'h0)
                                             ? (write_to_read_counter[3:0] - 4'h1) : 4'h0;
          write_recovery_counter[3:0]       <= (write_recovery_counter[3:0] != 4'h0)
                                             ? (write_recovery_counter[3:0] - 4'h1) : 4'h0;
          precharge_counter[3:0]            <= PRECHARGE_CYCLES;
          refresh_counter[3:0]              <= 4'h0;
        end

      WAITING_FOR_AUTO_PRECHARGE:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            if (   (write_recovery_counter[3:0] > 4'h1)
                 | (act_to_precharge_counter[3:0] > 4'h1) )
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
              Timing_Error <= 1'b0;
            end
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Activate to a bank which is being auto_precharging %t", $time);
              Timing_Error <= 1'b1;
            end
            if (   (write_recovery_counter[3:0] > 4'h1)
                 | (act_to_precharge_counter[3:0] > 4'h1) )
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
              Timing_Error <= 1'b0;
            end
          end
          else if (control_wires[4:0] == READ_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do a Read until bank completes precharge %t", $time);
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            if (   (write_recovery_counter[3:0] > 4'h1)
                 | (act_to_precharge_counter[3:0] > 4'h1) )
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
              Timing_Error <= 1'b0;
            end
          end
          else if (control_wires[4:0] == WRITE_BANK)
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do a Write until bank completes precharge %t", $time);
              Timing_Error <= 1'b1;
              burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                                 ? (burst_counter[3:0] - 4'h1) : 4'h0;
            end
            if (   (write_recovery_counter[3:0] > 4'h1)
                 | (act_to_precharge_counter[3:0] > 4'h1) )
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
              Timing_Error <= 1'b0;
            end
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)  // do idles when it is safe to do so
          begin
             if (   (write_recovery_counter[3:0] > 4'h1)
                 | (act_to_precharge_counter[3:0] > 4'h1) )
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
              Timing_Error <= 1'b0;
            end
          end
          else
          begin
            $display ("*** %m DDR DRAM can only wait from Write_precharge %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= WAITING_FOR_AUTO_PRECHARGE;
            Timing_Error <= 1'b1;
          end
          load_mode_delay_counter[3:0]      <= 4'h0;
          act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
          act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                             ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
          act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                             ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                             ? (burst_counter[3:0] - 4'h1) : 4'h0;
          read_to_write_counter [3:0]       <= (read_to_write_counter[3:0] != 4'h0)
                                             ? (read_to_write_counter[3:0] - 4'h1) : 4'h0;
          write_to_read_counter [3:0]       <= (write_to_read_counter[3:0] != 4'h0)
                                             ? (write_to_read_counter[3:0] - 4'h1) : 4'h0;
          write_recovery_counter[3:0]       <= (write_recovery_counter[3:0] != 4'h0)
                                             ? (write_recovery_counter[3:0] - 4'h1) : 4'h0;
          precharge_counter[3:0]            <= PRECHARGE_CYCLES;
          refresh_counter[3:0]              <= 4'h0;
        end

      PRECHARGING:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            if (precharge_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
              Timing_Error <= 1'b0;
            end
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Activate to a bank which is being Precharged %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              Timing_Error <= 1'b0;
            end
            if (precharge_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            end
          end
          else if (control_wires[4:0] == READ_BANK)  // no bank involved
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Read to a bank which is being Precharged %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              Timing_Error <= 1'b0;
            end
            if (precharge_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            end
          end
          else if (control_wires[4:0] == WRITE_BANK)  // no bank involved
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Write to a bank which is being Precharged %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              Timing_Error <= 1'b0;
            end
            if (precharge_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            end
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)  // ignore extra precharges
          begin
            Timing_Error <= 1'b0;
            if (precharge_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            end
          end
          else
          begin
            $display ("*** %m DDR DRAM can't do anything from Precharge %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= PRECHARGING;
            Timing_Error <= 1'b1;
          end
          load_mode_delay_counter[3:0]      <= (load_mode_delay_counter[3:0] != 4'h0)
                                             ? (load_mode_delay_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
          act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                             ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
          act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                             ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                             ? (burst_counter[3:0] - 4'h1) : 4'h0;
          read_to_write_counter [3:0]       <= (read_to_write_counter[3:0] != 4'h0)
                                             ? (read_to_write_counter[3:0] - 4'h1) : 4'h0;
          write_to_read_counter [3:0]       <= (write_to_read_counter[3:0] != 4'h0)
                                             ? (write_to_read_counter[3:0] - 4'h1) : 4'h0;
          write_recovery_counter[3:0]       <= (write_recovery_counter[3:0] != 4'h0)
                                             ? (write_recovery_counter[3:0] - 4'h1) : 4'h0;
          precharge_counter[3:0]            <= (precharge_counter[3:0] != 4'h0)
                                             ? (precharge_counter[3:0] - 4'h1) : 4'h0;
          refresh_counter[3:0]              <= (refresh_counter[3:0] != 4'h0)
                                             ? (refresh_counter[3:0] - 4'h1) : 4'h0;
        end

      REFRESHING:
         begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            if (refresh_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= REFRESHING;
              Timing_Error <= 1'b0;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
              Timing_Error <= 1'b0;
            end
          end
          else if (control_wires[4:0] == ACTIVATE_BANK)  // activate only if this bank is addressed
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Activate to a bank which is being Refreshed %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              Timing_Error <= 1'b0;
            end
            if (refresh_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= REFRESHING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            end
          end
          else if (control_wires[4:0] == READ_BANK)  // no bank involved
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Read to a bank which is being Refreshed %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              Timing_Error <= 1'b0;
            end
            if (refresh_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= REFRESHING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            end
          end
          else if (control_wires[4:0] == WRITE_BANK)  // no bank involved
          begin
            if (BA[1:0] == bank_num[1:0])
            begin
              $display ("*** %m DDR DRAM cannot do an Write to a bank which is being Refreshed %t", $time);
              Timing_Error <= 1'b1;
            end
            else
            begin
              Timing_Error <= 1'b0;
            end
            if (refresh_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= REFRESHING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            end
          end
          else if (control_wires[4:0] == PRECHARGE_BANK)  // ignore extra precharges
          begin
            Timing_Error <= 1'b0;
            if (refresh_counter[3:0] > 4'h2)  // looping
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= REFRESHING;
            end
            else
            begin
              bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
            end
          end
          else
          begin
            $display ("*** %m DDR DRAM can't do anything from Refresh %t", $time);
            bank_state[BANK_STATE_WIDTH - 1 : 0] <= REFRESHING;
            Timing_Error <= 1'b1;
          end
          load_mode_delay_counter[3:0]      <= (load_mode_delay_counter[3:0] != 4'h0)
                                             ? (load_mode_delay_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_b_counter[3:0]       <= (act_a_to_act_b_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_b_counter[3:0] - 4'h1) : 4'h0;
          act_to_read_or_write_counter[3:0] <= (act_to_read_or_write_counter[3:0] != 4'h0)
                                             ? (act_to_read_or_write_counter[3:0] - 4'h1) : 4'h0;
          act_to_precharge_counter[3:0]     <= (act_to_precharge_counter[3:0] != 4'h0)
                                             ? (act_to_precharge_counter[3:0] - 4'h1) : 4'h0;
          act_a_to_act_a_counter[3:0]       <= (act_a_to_act_a_counter[3:0] != 4'h0)
                                             ? (act_a_to_act_a_counter[3:0] - 4'h1) : 4'h0;
          burst_counter[3:0]                <= (burst_counter[3:0] != 4'h0)
                                             ? (burst_counter[3:0] - 4'h1) : 4'h0;
          write_recovery_counter[3:0]       <= (write_recovery_counter[3:0] != 4'h0)
                                             ? (write_recovery_counter[3:0] - 4'h1) : 4'h0;
          precharge_counter[3:0]            <= (precharge_counter[3:0] != 4'h0)
                                             ? (precharge_counter[3:0] - 4'h1) : 4'h0;
          refresh_counter[3:0]              <= (refresh_counter[3:0] != 4'h0)
                                             ? (refresh_counter[3:0] - 4'h1) : 4'h0;
        end

      default:
        begin
          $display ("*** %m DDR DRAM default jump should be impossible %t", $time);
          bank_state[BANK_STATE_WIDTH - 1 : 0] <= BANK_IDLE;
          Timing_Error <= 1'b1;
        end
    endcase
    end  // if out the entire case statement!
  end
endmodule

`define TEST_DDR_2_DRAM
`ifdef TEST_DDR_2_DRAM
module test_ddr_2_dram;
  reg  CLK_P, CLK_N;

  initial
  begin
    CLK_P <= 1'b0;
    CLK_N <= 1'b1;
    # 10_000 ;  // make times be even
    while (1'b1)
    begin
      #10_000 ;  // 10 nSec
      CLK_P <= ~CLK_P;
      CLK_N <= ~CLK_N;
    end
  end

  initial
  begin
    #2000_000 $finish;
  end

// hook up sequential test bench to instantiation of DDR DRAM for test
parameter DATA_BUS_WIDTH = 4;

  wire   [DATA_BUS_WIDTH - 1 : 0] DQ;
  wire    DQS;

  reg     DM;
  reg    [12:0] A;
  reg    [1:0] BA;
  reg     RAS_L, CAS_L, WE_L, CS_L, CKE;
  reg    [DATA_BUS_WIDTH - 1 : 0] DQ_out_0;
  reg    [DATA_BUS_WIDTH - 1 : 0] DQ_out_1;
  reg     DQ_oe_0, DQ_oe_1;
  reg     DQS_out;
  reg     DQS_oe;

// MUX the two data items together based on clock phase
  wire   [DATA_BUS_WIDTH - 1 : 0] DQ_out = CLK_P
                ? DQ_out_1[DATA_BUS_WIDTH - 1 : 0]
                : DQ_out_0[DATA_BUS_WIDTH - 1 : 0];

// Either send data or tristate the bus
  assign  DQ[DATA_BUS_WIDTH - 1 : 0] = DQ_oe
                ? DQ_out[DATA_BUS_WIDTH - 1 : 0]
                : {DATA_BUS_WIDTH{1'bZ}};

// The DQS signal is OE'd BEFORE the Data.  Called the preamble.
  assign DQS = DQS_oe ? DQS_out : 1'bZ;

// {CKE, CS_L, RAS_L, CAS_L, WE_L}
parameter NOOP      = 5'h17;
parameter ACTIVATE  = 5'h13;
parameter READ      = 5'h15;
parameter WRITE     = 5'h14;
parameter PRECHARGE = 5'h12;
parameter REFRESH   = 5'h11;
parameter LOAD_MODE = 5'h10;

  initial
  begin
DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'hZ;
DQ_oe_0 <= 1'b0;
DQ_out_1[DATA_BUS_WIDTH - 1 : 0] <= 4'hZ;
DQ_oe_1 <= 1'b0;

    CKE <= 1'b1;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    DQ_oe <= 1'b0;  DQS_oe <= 1'b0;
    @ (posedge CLK_P) ;  // noop

A[12:0] <= 13'h1555;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= LOAD_MODE;
    @ (posedge CLK_P) ;  // write reg

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= ACTIVATE;
    @ (posedge CLK_P) ;  // activate

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= WRITE;
    @ (posedge CLK_P) ;  // write DRAM

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'h1;
DQ_out_1[DATA_BUS_WIDTH - 1 : 0] <= 4'hZ;

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'h2;
DQ_out_1[DATA_BUS_WIDTH - 1 : 0] <= 4'hE;

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= WRITE;
    @ (posedge CLK_P) ;  // write DRAM

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'h3;
DQ_out_1[DATA_BUS_WIDTH - 1 : 0] <= 4'hD;

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'h4;
DQ_out_1[DATA_BUS_WIDTH - 1 : 0] <= 4'hC;

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'hZ;
DQ_out_1[DATA_BUS_WIDTH - 1 : 0] <= 4'hB;

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

DQ_out_1[DATA_BUS_WIDTH - 1 : 0] <= 4'hZ;

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= READ;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= READ;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= PRECHARGE;
    @ (posedge CLK_P) ;  // noop

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= ACTIVATE;
    @ (posedge CLK_P) ;  // activate

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= READ;
    @ (posedge CLK_P) ;  // read

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data  //

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= WRITE;
    @ (posedge CLK_P) ;  // write

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'hE;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'hD;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'hZ;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data


A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= PRECHARGE;
    @ (posedge CLK_P) ;  // noop

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= REFRESH;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= ACTIVATE;
    @ (posedge CLK_P) ;  // activate

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

A[12:0] <= 13'h400;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= WRITE;
    @ (posedge CLK_P) ;  // write

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'hB;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'h7;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

DQ_out_0[DATA_BUS_WIDTH - 1 : 0] <= 4'hZ;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= ACTIVATE;
    @ (posedge CLK_P) ;  // activate

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

A[12:0] <= 13'h400;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= READ;
    @ (posedge CLK_P) ;  // write

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

A[12:0] <= 13'h0;  BA[1:0] <= 2'h0;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= ACTIVATE;
    @ (posedge CLK_P) ;  // activate

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

  end




  assign  DQ[DATA_BUS_WIDTH - 1 : 0] =
                  (   (DQ_out_0[DATA_BUS_WIDTH - 1 : 0] !== {DATA_BUS_WIDTH{1'bZ}})
                    & (CLK_N == 1'b1) )
                ? DQ_out_0[DATA_BUS_WIDTH - 1 : 0]
                : ( (   (DQ_out_1[DATA_BUS_WIDTH - 1 : 0] !== {DATA_BUS_WIDTH{1'bZ}})
                      & (CLK_P == 1'b1) )
                  ? DQ_out_1[DATA_BUS_WIDTH - 1 : 0]
                  : {DATA_BUS_WIDTH{1'bZ}});

ddr_2_dram
# ( 100.0,  // frequency
    2.0,  // latency
    13,  // num_addr_bits
    12,  // num_col_bits
     4 * DATA_BUS_WIDTH,  // num_data_bits
    32,  // num_words_in_test_memory
     1
  ) ddr_2_dram (
  .DQ                         ({DQ[DATA_BUS_WIDTH - 1 : 0], DQ[DATA_BUS_WIDTH - 1 : 0],
                                DQ[DATA_BUS_WIDTH - 1 : 0], DQ[DATA_BUS_WIDTH - 1 : 0]}),
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

  wire   [3:0] BANK_STATE_0 = ddr_2_dram.ddr_2_dram_single_bank_0.bank_state[3:0];
  wire   [3:0] BANK_STATE_1 = ddr_2_dram.ddr_2_dram_single_bank_1.bank_state[3:0];
  wire   [3:0] BANK_STATE_2 = ddr_2_dram.ddr_2_dram_single_bank_2.bank_state[3:0];
  wire   [3:0] BANK_STATE_3 = ddr_2_dram.ddr_2_dram_single_bank_3.bank_state[3:0];

endmodule
`endif  // TEST_DDR_2_DRAM
