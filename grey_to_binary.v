//////////////////////////////////////////////////////////////////////
////                                                              ////
//// grey_to_binary #(N), binary_to_grey #(N)                     ////
////                                                              ////
//// This file is part of the general opencores effort.           ////
//// <http://www.opencores.org/cores/misc/>                       ////
////                                                              ////
//// Module Description:                                          ////
////    Example of how to convert Grey Code to Binary.            ////
////    Example of how to convert Binary to Grey Code.            ////
////                                                              ////
//// CRITICAL USAGE NOTE:                                         ////
////    These functions produce combinational outputs which       ////
////      have glitches.  To use these safely, the outputs        ////
////      must be latched using the same clock before and         ////
////      after the combinational function.                       ////
////                                                              ////
////    There are other sequences of numbers which share the      ////
////      property of Grey Code that only 1 bit transitions per   ////
////      value change.                                           ////
////    The sequence 0x00, 0x1, 0x3, 0x2, 0x6, 0x4 is one such    ////
////      sequence.                                               ////
////    It should be possible to make a library which counts      ////
////      in sequences less than 2**n long, yet which still       ////
////      change only 1 bot per increment.                        ////
////                                                              ////
//// To Do:                                                       ////
//// Might make this handle more than 16 bits.                    ////
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
// $Id: grey_to_binary.v,v 1.5 2001-10-22 12:29:08 bbeaver Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2001/09/03 12:12:44  Blue Beaver
// no message
//
// Revision 1.2  2001/09/03 12:09:24  Blue Beaver
// no message
//
//

`timescale 1ns/1ps

// Convert 2-bit up to 16-bit binary value into same sized grey-code value

module bin_to_grey_code (
  grey_code_out,
  binary_in
);
  parameter NUM_BITS = 1;  // instantiate as "bin_to_grey_code #(width) instance ()"

  output [NUM_BITS - 1 : 0] grey_code_out;
  input  [NUM_BITS - 1 : 0] binary_in;

// Consider the sequences
//   Binary  Grey Code
//     00       00
//     01       01
//     10       11
//     11       10
// It seems that G[1] = B[1], and G[0] = B[1] ^ B[0];
// Now consider the sequences
//   Binary  Grey Code
//     000      000
//     001      001
//     010      011
//     011      010
//     100      110
//     101      111
//     110      101
//     111      100
// It seems that G[2] = B[2], and
//               G[1] = B[2] ^ B[1], and
//               G[0] = B[1] ^ B[0];
//
// But how to write that using a parameter?  Well, instead of
//   figuring it out, how about just making something which works
//   for a range of widths, like 2 to 16?

  wire   [15:0] widened_input = {binary_in[NUM_BITS - 1 : 0], {16 - NUM_BITS{1'b0}}};

  wire   [15:0] widened_output = {
                      widened_input[15],
                      widened_input[15] ^ widened_input[14],
                      widened_input[14] ^ widened_input[13],
                      widened_input[13] ^ widened_input[12],
                      widened_input[12] ^ widened_input[11],
                      widened_input[11] ^ widened_input[10],
                      widened_input[10] ^ widened_input[9],
                      widened_input[9]  ^ widened_input[8],
                      widened_input[8]  ^ widened_input[7],
                      widened_input[7]  ^ widened_input[6],
                      widened_input[6]  ^ widened_input[5],
                      widened_input[5]  ^ widened_input[4],
                      widened_input[4]  ^ widened_input[3],
                      widened_input[3]  ^ widened_input[2],
                      widened_input[2]  ^ widened_input[1],
                      widened_input[1]  ^ widened_input[0]
                  };

  assign  grey_code_out[NUM_BITS - 1 : 0] = widened_output[15 : 16 - NUM_BITS];

// synopsys translate_off
  initial
  begin
    if (NUM_BITS < 2)
    begin
      $display ("*** Exiting because %m bin_to_grey_code Number of bits %d < 2",
                   NUM_BITS);
      $finish;
    end
    if (NUM_BITS > 16)
    begin
      $display ("*** Exiting because %m bin_to_grey_code Number of bits %d > 16",
                   NUM_BITS);
      $finish;
    end
  end
// synopsys translate_on
endmodule

// Convert 2-bit up to 16-bit binary value into same sized grey-code value

module grey_code_to_bin (
  binary_out,
  grey_code_in
);
  parameter NUM_BITS = 1;  // instantiate as "grey_code_to_bin #(width) instance ()"

  output [NUM_BITS - 1 : 0] binary_out;
  input  [NUM_BITS - 1 : 0] grey_code_in;

// Consider the sequences
//   Grey Code   Binary
//       00        00
//       01        01
//       11        10
//       10        11
// It seems that B[1] = G[1], and B[0] = G[1] ^ G[0];
// Now consider the sequences
//   Grey Code   Binary
//      000       000
//      001       001
//      011       010
//      010       011
//      110       100
//      111       101
//      101       110
//      100       111
// It seems that B[2] = G[2], and
//               B[1] = G[2] ^ G[1], and
//               B[0] = G[2] ^ G[1] ^ G[0];
//
// But how to write that using a parameter?  Well, instead of
//   figuring it out, how about just making something which works
//   for a range of widths, like 2 to 16?

  wire   [15:0] widened_input = {grey_code_in[NUM_BITS - 1 : 0], {16 - NUM_BITS{1'b0}}};
  wire    xor_15_12 = widened_input[15] ^ widened_input[14]
                    ^ widened_input[13] ^ widened_input[12];
  wire    xor_11_10 = widened_input[11] ^ widened_input[10];
  wire    xor_11_8  = widened_input[11] ^ widened_input[10]
                    ^ widened_input[9]  ^ widened_input[8];
  wire    xor_7_6   = widened_input[7]  ^ widened_input[6];
  wire    xor_7_4   = widened_input[7]  ^ widened_input[6]
                    ^ widened_input[5]  ^ widened_input[4];
  wire    xor_3_2   = widened_input[3]  ^ widened_input[2];
  wire    xor_1_0   = widened_input[1]  ^ widened_input[0];

  wire   [15:0] widened_output = {
                      widened_input[15],
                      widened_input[15] ^ widened_input[14],
                      widened_input[15] ^ widened_input[14] ^ widened_input[13],
                      xor_15_12,
                      xor_15_12 ^ widened_input[11],
                      xor_15_12 ^ xor_11_10,
                      xor_15_12 ^ xor_11_10 ^ widened_input[9],
                      xor_15_12 ^ xor_11_8,
                      xor_15_12 ^ xor_11_8 ^ widened_input[7],
                      xor_15_12 ^ xor_11_8 ^ xor_7_6,
                      xor_15_12 ^ xor_11_8 ^ xor_7_6 ^ widened_input[5],
                      xor_15_12 ^ xor_11_8 ^ xor_7_4,
                      xor_15_12 ^ xor_11_8 ^ xor_7_4 ^ widened_input[3],
                      xor_15_12 ^ xor_11_8 ^ xor_7_4 ^ xor_3_2,
                      xor_15_12 ^ xor_11_8 ^ xor_7_4 ^ xor_3_2 ^ widened_input[1],
                      xor_15_12 ^ xor_11_8 ^ xor_7_4 ^ xor_3_2 ^ xor_1_0
                  };

  assign  binary_out[NUM_BITS - 1 : 0] = widened_output[15 : 16 - NUM_BITS];

// synopsys translate_off
  initial
  begin
    if (NUM_BITS < 2)
    begin
      $display ("*** Exiting because %m grey_code_to_bin Number of bits %d < 2",
                   NUM_BITS);
      $finish;
    end
    if (NUM_BITS > 16)
    begin
      $display ("*** Exiting because %m grey_code_to_bin Number of bits %d > 16",
                   NUM_BITS);
      $finish;
    end
  end
// synopsys translate_on
endmodule

 `define TEST_GREY_CODE
`ifdef TEST_GREY_CODE
module test_grey_code;
  reg    [7:0] test_val;
  wire   [1:0] grey_2;
  wire   [2:0] grey_3;
  wire   [3:0] grey_4;

  wire   [1:0] bin_2;
  wire   [2:0] bin_3;
  wire   [3:0] bin_4;

  initial
  begin
    for (test_val = 8'h00; test_val < 8'h04; test_val = test_val + 8'h01)
    begin
      # 0; $display ("test val, result %x %x %x", test_val[1:0], grey_2[1:0], bin_2[1:0]);
      if (test_val[1:0] !== bin_2[1:0])
        $display ("*** Encode, Decode failed %x %x", test_val[1:0], bin_2[1:0]);
    end
    $display (" ");
    for (test_val = 8'h00; test_val < 8'h08; test_val = test_val + 8'h01)
    begin
      # 0; $display ("test val, result %x %x %x", test_val[2:0], grey_3[2:0], bin_3[2:0]);
      if (test_val[2:0] !== bin_3[2:0])
        $display ("*** Encode, Decode failed %x %x", test_val[2:0], bin_3[2:0]);
    end
    $display (" ");
    for (test_val = 8'h00; test_val < 8'h10; test_val = test_val + 8'h01)
    begin
      # 0; $display ("test val, result %x %x %x", test_val[3:0], grey_4[3:0], bin_4[3:0]);
      if (test_val[3:0] !== bin_4[3:0])
        $display ("*** Encode, Decode failed %x %x", test_val[3:0], bin_4[3:0]);
    end

  end

bin_to_grey_code #(2) bin_to_grey_code_2 (
  .grey_code_out              (grey_2[1:0]),
  .binary_in                  (test_val[1:0])
);
bin_to_grey_code #(3) bin_to_grey_code_3 (
  .grey_code_out              (grey_3[2:0]),
  .binary_in                  (test_val[2:0])
);
bin_to_grey_code #(4) bin_to_grey_code_4 (
  .grey_code_out              (grey_4[3:0]),
  .binary_in                  (test_val[3:0])
);

grey_code_to_bin #(2) grey_code_to_bin_2 (
  .binary_out                 (bin_2[1:0]),
  .grey_code_in               (grey_2[1:0])
);
grey_code_to_bin #(3) grey_code_to_bin_3 (
  .binary_out                 (bin_3[2:0]),
  .grey_code_in               (grey_3[2:0])
);
grey_code_to_bin #(4) grey_code_to_bin_4 (
  .binary_out                 (bin_4[3:0]),
  .grey_code_in               (grey_4[3:0])
);

endmodule
`endif  // TEST_GREY_CODE

