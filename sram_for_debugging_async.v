//////////////////////////////////////////////////////////////////////
////                                                              ////
//// sram_for_debugging_async  #(NUM_ADDR_BITS, NUM_DATA_BITS)    ////
////                                                              ////
//// This file is part of the general opencores effort.           ////
//// <http://www.opencores.org/cores/misc/>                       ////
////                                                              ////
//// Module Description:                                          ////
////    An SRAM model which contains only 32 entries.             ////
////    This SRAM trades off time for storage.  By only storing   ////
////      a very few entries, this SRAM takes constant storage    ////
////      independent of how many address lines it exports.       ////
////    The limited storage means that the entries must be read   ////
////      soon after it is written.  If too many writes happen    ////
////      before an entry is read, the entry returns X's.         ////
////    This SRAM has 1 other debugging feature.  When a write    ////
////      is executed, the SRAM ;atches the bit number of the     ////
////      least significant bit of the address which is HIGH.     ////
////    The special address 0xAA00..., with the top 8 bits being  ////
////      8'b1010_1010, returns the stored number when read.      ////
////    As an example, assume that a write is done to location    ////
////      20'h0_0040.                                             ////
////    After the write, but before any other write, the user     ////
////      can read location 20'hC_C000.  The read returns 4'h5.   ////
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
// $Id: sram_for_debugging_async.v,v 1.2 2001-11-06 12:33:15 bbeaver Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2001/10/02 05:23:27  Blue Beaver
// no message
//
// Revision 1.3  2001/09/27 08:05:43  Blue Beaver
// no message
//
// Revision 1.2  2001/09/26 09:46:20  Blue Beaver
// no message
//
// Revision 1.1  2001/09/25 10:49:34  Blue Beaver
// no message
//

`timescale 1ns/1ps

// instantiate as "sram_for_debugging_async #(NUM_ADDR_BITS, NUM_DATA_BITS) instance ()"

module sram_for_debugging_async (
  data_out,
  data_in,
  address,
  read_enable,
  write_enable
);
  parameter NUM_ADDR_BITS = 1;
  parameter NUM_DATA_BITS = 1;

  output [NUM_DATA_BITS - 1 : 0] data_out;
  input  [NUM_DATA_BITS - 1 : 0] data_in;
  input  [NUM_ADDR_BITS - 1 : 0] address;
  input   read_enable;
  input   write_enable;

  reg    [NUM_DATA_BITS - 1 : 0] data_storage [31:0];  // 32 entries of SRAM storage
  reg    [NUM_ADDR_BITS - 1 : 0] address_storage [31:0];  // 32 entries of SRAM storage
  reg    [5:0] write_counter;  // enough to count to 63
  reg    [NUM_DATA_BITS - 1 : 0] stored_write_address;  // store bit number of address LSB set to 1

  integer i, j, k, l;

// synopsys translate_off
  initial
  begin
    for (i = 6'h00; i != 6'h20; i = i + 6'h01)
    begin
      address_storage[i] = {NUM_ADDR_BITS{1'bX}};
      data_storage[i] = {NUM_DATA_BITS{1'bX}};
      stored_write_address[NUM_DATA_BITS - 1 : 0] = {NUM_DATA_BITS{1'bX}};
      write_counter[5:0] = 6'h00;
    end
  end
// synopsys translate_on

// Write to next address, remember which LSB write address bit was ~0
  always @(posedge write_enable)
  begin
    address_storage[write_counter[4:0]] = address[NUM_ADDR_BITS - 1 : 0];
    data_storage[write_counter[4:0]] = data_in[NUM_DATA_BITS - 1 : 0];
    for (j = 0; j < NUM_ADDR_BITS; j = j + 1)
    begin
      if (((address[NUM_ADDR_BITS - 1 : 0] >> j) & 1'b1) != 1'b0)
      begin
        stored_write_address[NUM_DATA_BITS - 1 : 0] = j;
        j = NUM_ADDR_BITS + 1;  // only remember the FIRST bit set
      end
    end
    if (j == NUM_ADDR_BITS)  // NO bit was set
    begin
      stored_write_address[NUM_DATA_BITS - 1 : 0] = NUM_ADDR_BITS;
    end
    write_counter[5:0] = (write_counter[5:0] + 6'h01) & 6'h1F;
  end

// Starting at the newest, search back to oldest to find if the word has been written
  reg    [NUM_DATA_BITS - 1 : 0] data_out;
  reg    [4:0] read_address;

  always @(read_enable)
  begin
    if ((read_enable !== 1'b1) | ((^address[NUM_DATA_BITS - 1 : 0]) === 1'bX))  // no read, return X's
    begin
      data_out[NUM_DATA_BITS - 1 : 0] = {NUM_DATA_BITS{1'bX}};
    end
    else
    begin
      if ((address[NUM_ADDR_BITS - 1 : 0] >> (NUM_ADDR_BITS - 8)) == 8'hAA)  // read magic location, return Address Bit Number
      begin
        data_out[NUM_DATA_BITS - 1 : 0] = stored_write_address[NUM_DATA_BITS - 1 : 0];
      end
      else  // otherwise search history to see if the word has been written recently
      begin
        k = write_counter[5:0];
        for (l = k + 6'h1F;  // half way around, same as last minus 1;
             l >= k;  // write address not valid
             l = l - 1)
        begin
          read_address[4:0] = l;
          if (address[NUM_ADDR_BITS - 1 : 0] === address_storage[read_address[4:0]])
          begin
            data_out[NUM_DATA_BITS - 1 : 0] = data_storage[read_address[4:0]];
            l = k - 2;
          end
        end
        if (l == (k - 1))  // didn't find it at all!
        begin
          data_out[NUM_DATA_BITS - 1 : 0] = {NUM_DATA_BITS{1'bX}};
        end
      end
    end
  end

// synopsys translate_off
  initial
  begin
    if (NUM_ADDR_BITS < 8)
    begin
      $display ("*** Exiting because %m sram_for_debugging_async Number of Address bits %d < 8",
                   NUM_ADDR_BITS);
      $finish;
    end
    if (NUM_DATA_BITS < 8)
    begin
      $display ("*** Exiting because %m sram_for_debugging_async Number of Data bits %d < 8",
                   NUM_DATA_BITS);
      $finish;
    end
  end
// synopsys translate_on
endmodule

`define TEST_SRAM
`ifdef TEST_SRAM
module test_sram;
  reg    [11:0] address;
  reg    [8:0] data_in;
  reg     read_enable, write_enable;
  wire   [8:0] data_out;

  integer i;

  initial
  begin
    read_enable = 1'b0;
    write_enable = 1'b0;
    for (i = 0; i < 12; i = i + 1)
    begin
      # 0;
      address[11:0] = (12'h001 << i);
      data_in[8:0] = i + 4;
      # 0; write_enable = 1'b1;
      # 0; write_enable = 1'b0;
      # 0;
      address[11:0] = 12'hAA0;
      # 0; read_enable = 1'b1;
      # 0;
      if (data_out[8:0] !== i)
        $display ("*** Debug SRAM read failed %x %x", i, data_out[8:0]);
      # 0; read_enable = 1'b0;
    end

    for (i = 0; i < 12; i = i + 1)
    begin
      # 0;
      address[11:0] = (12'h001 << i);
      # 0; read_enable = 1'b1;
      # 0;
      if (data_out[8:0] !== (i + 4))
        $display ("*** Debug SRAM read failed %x %x", i, data_out[8:0]);
      # 0; read_enable = 1'b0;
    end

    # 0;
    address[11:0] = 12'hXXX;
    # 0; read_enable = 1'b1;
    # 0;
    if (data_out[8:0] !== 9'hXXX)
      $display ("*** Debug SRAM read failed %x %x", i, data_out[8:0]);
    # 0; read_enable = 1'b0;

    # 0;
    address[11:0] = 12'h003;
    # 0; read_enable = 1'b1;
    # 0;
    if (data_out[8:0] !== 9'hXXX)
      $display ("*** Debug SRAM read failed %x %x", i, data_out[8:0]);
    # 0; read_enable = 1'b0;

    for (i = 0; i < 32; i = i + 1)
    begin
      # 0;
      address[11:0] = i;
      data_in[8:0] = i + 32;
      # 0; write_enable = 1'b1;
      # 0; write_enable = 1'b0;
    end

    for (i = 0; i < 32; i = i + 1)
    begin
      # 0;
      address[11:0] = i;
      # 0; read_enable = 1'b1;
      # 0;
      if (data_out[8:0] !== (i + 32))
        $display ("*** Debug SRAM read failed %x %x", i, data_out[8:0]);
      # 0; read_enable = 1'b0;
    end

  end

sram_for_debugging_async
#(12,  // NUM_ADDR_BITS
   9   // NUM_DATA_BITS
 ) test_this_one (
  .data_out                   (data_out[8:0]),
  .data_in                    (data_in[8:0]),
  .address                    (address[11:0]),
  .read_enable                (read_enable),
  .write_enable               (write_enable)
);

endmodule
`endif  // TEST_SRAM

