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
// $Id: ddr_2_dram_for_debugging.v,v 1.2 2001-10-29 13:37:57 bbeaver Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2001/10/29 13:45:02  Blue Beaver
// no message
//
// Revision 1.4  2001/10/29 13:41:38  Blue Beaver
// no message
//
// Revision 1.3  2001/10/29 11:50:51  Blue Beaver
// no message
//
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
parameter FREQUENCY = 133.0;  // might be 100, 125, 166, any other frequency
parameter LATENCY = 2.0;  // might be 2.0, 2.5, 3.0, 3.5, 4.0
parameter NUM_ADDR_BITS = 13;
parameter NUM_COL_BITS  = 11;
parameter NUM_DATA_BITS =  4;
parameter NUM_WORDS_IN_TEST_MEMORY = 32;

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

  wire   [NUM_DATA_BITS - 1 : 0] DQ_out_0;
  wire    DQ_oe_0, DQS_out_0, DQS_oe_0;

  wire   [NUM_DATA_BITS - 1 : 0] DQ_out_1;
  wire    DQ_oe_1, DQS_out_1, DQS_oe_1;

  wire   [NUM_DATA_BITS - 1 : 0] DQ_out_2;
  wire    DQ_oe_2, DQS_out_2, DQS_oe_2;

  wire   [NUM_DATA_BITS - 1 : 0] DQ_out_3;
  wire    DQ_oe_3, DQS_out_3, DQS_oe_3;

  always @(    DQ_oe_0   or DQ_oe_1   or DQ_oe_2   or DQ_oe_3
            or DQS_out_0 or DQS_out_1 or DQS_out_2 or DQS_out_3
            or DQS_oe_0  or DQS_oe_1  or DQS_oe_2  or DQS_oe_3 )
  begin
    if (   (DQ_oe_0 & DQ_oe_1) | (DQ_oe_0 & DQ_oe_2) | (DQ_oe_0 & DQ_oe_3)
         | (DQ_oe_1 & DQ_oe_2) | (DQ_oe_1 & DQ_oe_3) | (DQ_oe_2 & DQ_oe_3) )
    begin
      $display ("*** %m DDR DRAM has multiple banks driving DQ at the same time at %x %t",
                    {DQ_oe_3, DQ_oe_2, DQ_oe_1, DQ_oe_0}, $time);
    end
    if (   ((DQS_oe_0 & DQS_oe_1) & (DQS_out_0 != DQS_out_1))
         | ((DQS_oe_0 & DQS_oe_2) & (DQS_out_0 != DQS_out_2))
         | ((DQS_oe_0 & DQS_oe_3) & (DQS_out_0 != DQS_out_3))
         | ((DQS_oe_1 & DQS_oe_2) & (DQS_out_1 != DQS_out_2))
         | ((DQS_oe_1 & DQS_oe_3) & (DQS_out_1 != DQS_out_3))
         | ((DQS_oe_2 & DQS_oe_3) & (DQS_out_2 != DQS_out_3)) )
    begin
      $display ("*** %m DDR DRAM has multiple banks driving DQS at the same time at %x %x %t",
                    {DQS_oe_3, DQS_oe_2, DQS_oe_1, DQS_oe_0},
                    {DQS_out_3, DQS_out_2, DQS_out_1, DQS_out_0}, $time);
    end

  end

  assign  DQ = force_x ? {NUM_DATA_BITS{1'hX}} : {NUM_DATA_BITS{1'h0}};
  assign  DQS = force_x ? 1'hX : 1'h0;


ddr_2_dram_single_bank
# ( FREQUENCY,
    LATENCY,
    NUM_ADDR_BITS,
    NUM_COL_BITS,
    NUM_DATA_BITS,
    NUM_WORDS_IN_TEST_MEMORY
  ) ddr_2_dram_single_bank_0 (
  .DQ                         (DQ[NUM_DATA_BITS - 1 : 0]),
  .DQS                        (DQS),
  .DQ_out                     (DQ_out_0[NUM_DATA_BITS - 1 : 0]),
  .DQ_oe                      (DQ_oe_0),
  .DQS_out                    (DQS_out_0),
  .DQS_oe                     (DQS_oe_0),
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
    NUM_WORDS_IN_TEST_MEMORY
  ) ddr_2_dram_single_bank_1 (
  .DQ                         (DQ[NUM_DATA_BITS - 1 : 0]),
  .DQS                        (DQS),
  .DQ_out                     (DQ_out_1[NUM_DATA_BITS - 1 : 0]),
  .DQ_oe                      (DQ_oe_1),
  .DQS_out                    (DQS_out_1),
  .DQS_oe                     (DQS_oe_1),
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
    NUM_WORDS_IN_TEST_MEMORY
  ) ddr_2_dram_single_bank_2 (
  .DQ                         (DQ[NUM_DATA_BITS - 1 : 0]),
  .DQS                        (DQS),
  .DQ_out                     (DQ_out_2[NUM_DATA_BITS - 1 : 0]),
  .DQ_oe                      (DQ_oe_2),
  .DQS_out                    (DQS_out_2),
  .DQS_oe                     (DQS_oe_2),
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
    NUM_WORDS_IN_TEST_MEMORY
  ) ddr_2_dram_single_bank_3 (
  .DQ                         (DQ[NUM_DATA_BITS - 1 : 0]),
  .DQS                        (DQS),
  .DQ_out                     (DQ_out_3[NUM_DATA_BITS - 1 : 0]),
  .DQ_oe                      (DQ_oe_3),
  .DQS_out                    (DQS_out_3),
  .DQS_oe                     (DQS_oe_3),
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
  DQ_out, DQ_oe,
  DQS_out, DQS_oe,
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
// Constant Parameters
parameter FREQUENCY = 133.0;  // might be 100, 125, 166, any other frequency
parameter LATENCY = 2.0;  // might be 2.0, 2.5, 3.0, 3.5, 4.0
parameter NUM_ADDR_BITS = 13;
parameter NUM_COL_BITS  = 11;
parameter NUM_DATA_BITS =  4;
parameter NUM_WORDS_IN_TEST_MEMORY = 32;

  input  [NUM_DATA_BITS - 1 : 0] DQ;
  input   DQS;
  output [NUM_DATA_BITS - 1 : 0] DQ_out;
  output  DQ_oe;
  output  DQS_out, DQS_oe;
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

// Storage
  reg    [NUM_DATA_BITS - 1 : 0] bank0 [0 : NUM_WORDS_IN_TEST_MEMORY - 1];

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

parameter NOOP      = 5'h17;
parameter ACTIVATE  = 5'h13;
parameter READ      = 5'h15;
parameter WRITE     = 5'h14;
parameter PRECHARGE = 5'h12;
parameter REFRESH   = 5'h11;
parameter LOAD_MODE = 5'h10;

  wire   [4:0] control_wires = {CKE, CS_L, RAS_L, CAS_L, WE_L};

// These are the important DDR DRAM timing specs in nanoseconds:
parameter load_mode_register_cycle_TMRD =   15.0;  // stay idle after load mode
parameter act_to_refresh_TRC =              65.0;
parameter act_a_to_act_a_TRC =              65.0;  // needed if failover
parameter act_a_to_act_b_TRRD =             15.0;  // Activate-to-activate minimum time
parameter act_to_precharge_TRAS =           40.0;
parameter act_to_read_or_write_TRCD =       20.0;
parameter write_end_to_precharge_TWR =      15.0;
parameter precharge_TRP =                   20.0;
parameter refresh_to_act_TRFC =             75.0;

// These timing requirements become CYCLE requirements, depending on the
//   operating frequency.  Note that 133.333 MHz = 7.5 nSec;
parameter load_mode_cycles              =     (FREQUENCY > 133.334) ? 2'h3 : 2'h2;
parameter act_to_refresh_cycles         =     (FREQUENCY > 123.075) ? 4'h9
                                           : ((FREQUENCY > 107.690) ? 4'h8
                                           : ((FREQUENCY >  92.300) ? 4'h7 : 4'h6));
parameter act_a_to_ack_a_cycles         =     (FREQUENCY > 123.075) ? 4'h9
                                           : ((FREQUENCY > 107.690) ? 4'h8
                                           : ((FREQUENCY >  92.300) ? 4'h7 : 4'h6));
parameter ack_a_to_ack_b_cycles         =     (FREQUENCY > 133.334) ? 2'h3 : 2'h2;
parameter ack_to_precharge_cycles       =     (FREQUENCY > 125.000) ? 4'h6
                                           : ((FREQUENCY > 100.000) ? 4'h5 : 4'h4);
parameter ack_to_read_or_write_cycles   =     (FREQUENCY > 100.000) ? 2'h3 : 2'h2;
parameter write_end_to_precharge_cycles =     (FREQUENCY > 133.334) ? 2'h3 : 2'h2;
parameter precharge_cycles              =     (FREQUENCY > 100.000) ? 2'h3 : 2'h2;
parameter refresh_to_ack_cycles         =     (FREQUENCY > 133.334) ? 4'hB
                                           : ((FREQUENCY > 120.000) ? 4'hA
                                           : ((FREQUENCY > 106.667) ? 4'h9
                                           : ((FREQUENCY >  93.330) ? 4'h8 : 4'h7)));

// The DDR-II DRAM has 4 banks.  Each bank can operate independently, with
//   only a few exceptions.
//
// Each bank needs counters to
// 1) prevent refresh too soon after activate
// 2) prevent activate to same bank too soon after activate
// 3) prevent activate to alternate bank too soon after activate
// 4) prevent (or notice) precharge too soon after activate
// 5) count out autorefresh delay

parameter POWER_ON               = 6'h00;
parameter BANK_IDLE_M2           = 6'h01;
parameter BANK_IDLE_M1           = 6'h02;
parameter BANK_IDLE              = 6'h03;
parameter BANK_ACTIVE_M2         = 6'h04;
parameter BANK_ACTIVE_M1         = 6'h05;
parameter BANK_ACTIVE            = 6'h06;
parameter BANK_READ_0            = 6'h07;
parameter BANK_READ_1            = 6'h08;
parameter BANK_READ_2            = 6'h09;
parameter BANK_READ              = 6'h0A;
parameter BANK_WRITE_0           = 6'h0B;
parameter BANK_WRITE_1           = 6'h0C;
parameter BANK_WRITE_2           = 6'h0D;
parameter BANK_WRITE             = 6'h0E;
parameter BANK_WRITE_p_0         = 6'h0F;
parameter BANK_WRITE_p_1         = 6'h10;
parameter BANK_WRITE_p_2         = 6'h11;

parameter BANK_REFRESH_M12       = 6'h32;
parameter BANK_REFRESH_M11       = 6'h33;
parameter BANK_REFRESH_M10       = 6'h34;
parameter BANK_REFRESH_M9        = 6'h35;
parameter BANK_REFRESH_M8        = 6'h36;
parameter BANK_REFRESH_M7        = 6'h37;
parameter BANK_REFRESH_M6        = 6'h38;
parameter BANK_REFRESH_M5        = 6'h39;
parameter BANK_REFRESH_M4        = 6'h3A;
parameter BANK_REFRESH_M3        = 6'h3B;
parameter BANK_REFRESH_M2        = 6'h3C;
parameter BANK_REFRESH_M1        = 6'h3D;
parameter BANK_REFRESH           = 6'h3E;
parameter BANK_ERROR             = 6'h3F;

parameter bank_state_width = 6;

  reg [bank_state_width - 1 : 0] bank_state;

  initial
  begin  // nail state to known at the start of simulation
    bank_state[bank_state_width - 1 : 0] = POWER_ON;  // nail it to known at the start of simulation
  end

  always @(posedge CLK_P)
  begin
    case (bank_state[bank_state_width - 1 : 0])
      POWER_ON:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            bank_state[bank_state_width - 1 : 0] <= POWER_ON;
          end
          else if (control_wires[4:0] == LOAD_MODE)  // no bank involved
          begin
            if (load_mode_cycles == 2'h3)
              bank_state[bank_state_width - 1 : 0] <= BANK_IDLE_M2;
            else
              bank_state[bank_state_width - 1 : 0] <= BANK_IDLE_M1;
          end
          else
          begin
            $display ("*** %m DDR DRAM needs to have a LOAD MODE REGISTER before any other command %t", $time);
            bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
          end
        end

      BANK_IDLE_M2:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            bank_state[bank_state_width - 1 : 0] <= BANK_IDLE_M1;
          end
          else
          begin
            $display ("*** %m DDR DRAM needs to have a NOOP after a LOAD MODE REGISTER command %t", $time);
            bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
          end
        end

      BANK_IDLE_M1:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
          end
          else
          begin
            $display ("*** %m DDR DRAM needs to have a NOOP after a LOAD MODE REGISTER command %t", $time);
            bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
          end
        end

      BANK_IDLE:
        begin
          if (   (control_wires[4] == 1'b0)      // powered off
               | (control_wires[3] == 1'b1)      // not selected
               | (control_wires[4:0] == NOOP) )  // noop
          begin
            bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
          end
          else if ((control_wires[4:0] == ACTIVATE) & (BA[1:0] != bank_num[1:0]))
          begin
            bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
          end
          else if ((control_wires[4:0] == ACTIVATE) & (BA[1:0] == bank_num[1:0]))
          begin
            if (ack_to_read_or_write_cycles == 2'h3)
              bank_state[bank_state_width - 1 : 0] <= BANK_ACTIVE_M2;
            else
              bank_state[bank_state_width - 1 : 0] <= BANK_ACTIVE_M1;
          end
          else if (control_wires[4:0] == REFRESH)
          begin
            bank_state[bank_state_width - 1 : 0] <= BANK_REFRESH_M2;
          end
          else if (control_wires[4:0] == LOAD_MODE)  // no bank involved
          begin
            if (load_mode_cycles == 2'h3)
              bank_state[bank_state_width - 1 : 0] <= BANK_IDLE_M2;
            else
              bank_state[bank_state_width - 1 : 0] <= BANK_IDLE_M1;
          end
          else
          begin
            $display ("*** %m DDR DRAM can only do Activate, Refresh, or Load Mode Register from Idle %t", $time);
            bank_state[bank_state_width - 1 : 0] <= BANK_ERROR;
          end
        end
      BANK_ACTIVE_M2:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_ACTIVE_M1:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_ACTIVE:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_READ_0:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_READ_1:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_READ_2:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_READ:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_WRITE_0:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_WRITE_1:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_WRITE_2:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_WRITE:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_REFRESH_M2:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_REFRESH_M1:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      BANK_REFRESH:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_IDLE;
        end
      default:
        begin
          bank_state[bank_state_width - 1 : 0] <= BANK_ERROR;
        end
    endcase
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
    #1000_000 $finish;
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
  reg     DQ_oe;
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
    CKE <= 1'b1;
    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    DQ_oe <= 1'b0;  DQS_oe <= 1'b0;
    @ (posedge CLK_P) ;  // noop

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
    @ (posedge CLK_P) ;  // activate

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

    {CKE, CS_L, RAS_L, CAS_L, WE_L} <= NOOP;
    @ (posedge CLK_P) ;  // noop + data

  end

ddr_2_dram
# ( 133.0,  // frequency
    2.0,  // latency
    13,  // num_addr_bits
    11,  // num_col_bits
     4,  // num_data_bits
    32   // num_words_in_test_memory
  ) ddr_2_dram (
  .DQ                         (DQ[DATA_BUS_WIDTH - 1 : 0]),
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

  wire   [4:0] BANK_STATE_0 = ddr_2_dram.ddr_2_dram_single_bank_0.bank_state[4:0];
  wire   [4:0] BANK_STATE_1 = ddr_2_dram.ddr_2_dram_single_bank_1.bank_state[4:0];
  wire   [4:0] BANK_STATE_2 = ddr_2_dram.ddr_2_dram_single_bank_2.bank_state[4:0];
  wire   [4:0] BANK_STATE_3 = ddr_2_dram.ddr_2_dram_single_bank_3.bank_state[4:0];

endmodule
`endif  // TEST_DDR_2_DRAM
