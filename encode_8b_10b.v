//////////////////////////////////////////////////////////////////////
////                                                              ////
//// encode_8b_10b #(N), decode_10b_8b #(N)                       ////
////                                                              ////
//// This file is part of the general opencores effort.           ////
//// <http://www.opencores.org/cores/misc/>                       ////
////                                                              ////
//// Module Description:                                          ////
////    Example of how to convert 8B data to 10B data.            ////
////    Example of how to convert 10B data to 8B data.            ////
////                                                              ////
//// NOTE:                                                        ////
////    These modules are based on information contained in       ////
////    "Implementing an 8B/10B Encoder/Decoder for Gigabit       ////
////     Ethernet" by Daniel Elftmann and Jing Hua Ma of Altera.  ////
////    The paper was given in the International IC Tiapei        ////
////    conferance in 1999.                                       ////
////                                                              ////
////    A second source of information is XAPP336 titled "Design  ////
////    of a 16B/20B Encoder/Decoder using a Coolrunner CPLD"     ////
////    found on the Xilinx web sire www.xilinx.com               ////
////                                                              ////
////    The best article describing this is at wildpackets.com    ////
////    http://www.wildpackets.com/compendium/GB/L1-GbEn.html     ////
////                                                              ////
////    Finally, this is covered in US patent 4,665,517.          ////
////    Unfortunately the US Patent Office online copy has        ////
////    missing figures and the tables are un-readable.           ////
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
// $Id: encode_8b_10b.v,v 1.1 2001-10-22 12:29:08 bbeaver Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.7  2001/10/22 12:36:12  Blue Beaver
// no message
//
// Revision 1.6  2001/10/22 11:54:58  Blue Beaver
// no message
//
// Revision 1.5  2001/10/21 11:37:28  Blue Beaver
// no message
//
// Revision 1.4  2001/10/21 10:17:34  Blue Beaver
// no message
//
// Revision 1.3  2001/10/21 03:40:52  Blue Beaver
// no message
//
// Revision 1.2  2001/10/21 02:27:39  Blue Beaver
// no message
//
// Revision 1.1  2001/10/21 01:36:14  Blue Beaver
// no message
//
//
//

`timescale 1ns/1ps


// These are the codes which are valid to use as control codes.
// I believe that they have names, but I don't know them.
// Note K_28_1, K_28_5, and K_28_7 contain Singular Commas.
`define K_28_0 8'b000_11100
`define K_28_1 8'b001_11100
`define K_28_2 8'b010_11100
`define K_28_3 8'b011_11100
`define K_28_4 8'b100_11100
`define K_28_5 8'b101_11100
`define K_28_6 8'b110_11100
`define K_28_7 8'b111_11100

`define K_23_7 8'b111_10111
`define K_27_7 8'b111_11011
`define K_29_7 8'b111_11101
`define K_30_7 8'b111_11110

// Convert 8-bit binary or 8-bit control code to 10-bit code

module encode_8b_10b (
  eight_bit_data_or_control_in,
  input_is_control,
  ten_bit_encoded_data_out,
  invalid_control,
  clk,
  reset
);

  input  [7:0] eight_bit_data_or_control_in;
  input   input_is_control;
  output [9:0] ten_bit_encoded_data_out;
  output  invalid_control;
  input   clk, reset;

// Data is treated as 2 fields.  The 3 MSB bits are treated as 1 field, and
//   the 5 LSB bits are treated as another field.
// The 5 LSB bits are encoded as 6 bits.  The 3 MSB bits are encoded as 4 bits.
// The encodings are chosen so that the 10 bits together have either
//   1) 5 1's and 5 0's,
//   2) 4 1's and 6 0's,
//   3  6 1's and 4 0's
// There are alternative encodings for the cases that the number of 1's and 0's
//   are not balanced.  The 8B/10B encoder keeps track of the running disparity
//   between the number of 1's and 0's, and uses alternate encodings to keep
//   the serial signal balanced with no disparity on average.
//
//  TABLE I 5B/6B ENCODING  (NOTE LSB TO LEFT)
//  NAME    ABCDE    K     D-1  abcdei  DO   ALTERNATE
//  ______________________________________
//  D.0     00000    0     +    011000  -    100111
//  D.1     10000    0     +    100010  -    011101   !
//  D.2     01000    0     +    010010  -    101101   !
//  D.3     11000    0     x    110001  0             !
//  D.4     00100    0     +    001010  -    110101   !
//  D.5     10100    0     x    101001  0             !
//  D.6     01100    0     x    011001  0             !
//  D.7     11100    0     -    111000  0    000111   !
//  D.8     00010    0     +    000110  -    111001   !
//  D.9     10010    0     x    100101  0             !
//  D.10    01010    0     x    010101  0             !
//  D.11    11010    0     x    110100  0             !
//  D.12    00110    0     x    001101  0             !
//  D.13    10110    0     x    101100  0             !
//  D.14    01110    0     x    011100  0             !
//  D.15    11110    0     +    101000  -    010111
//  D.16    00001    0     -    011011  +    100100
//  D.17    10001    0     x    100011  0             !
//  D.18    01001    0     x    010011  0             !
//  D.19    11001    0     x    110010  0             !
//  D.20    00101    0     x    001011  0             !
//  D.21    10101    0     x    101010  0             !
//  D.22    01101    0     x    011010  0             !
//  D.23    11101    x     -    111010  +    000101   !
//  D.24    00011    0     +    001100  -    110011
//  D.25    10011    0     x    100110  0             !
//  D.26    01011    0     x    010110  0             !
//  D.27    11011    x     -    110110  +    001001   !
//  D.28    00111    0     x    001110  0             !
//  D.29    10111    x     -    101110  +    010001   !
//  D.30    01111    x     -    011110  +    100001   !
//  D.31    11111    0     -    101011  +    010100
//
//  K.23    11101    x     -    111010  +    000101   !
//  K.27    11011    x     -    110110  +    001001   !
//  K.28    00111    1     -    001111  +    110000   !
//  K.29    10111    x     -    101110  +    010001   !
//  K.30    01111    x     -    011110  +    100001   !
//
//  TABLE II 3B/4B ENCODING  (NOTE LSB TO LEFT)
//  NAME     FGH     K     D-1   fghj   DO   ALTERNATE
//  ______________________________________ 
//  D.x.0    000     x     +     0100   -    1011 
//  D.x.1    100     0     x     1001   0             !
//  D.x.2    010     0     x     0101   0             !
//  D.x.3    110     x     -     1100   0    0011     !
//  D.x.4    001     x     +     0010   -    1101     !
//  D.x.5    101     0     x     1010   0             !
//  D.x.6    011     0     x     0110   0             !
//  D.x.P7   111     0     -     1110   +    0001     ! Primary
//  D.x.A7   111     x     -     0111   +    1000       Alternate
//
//  K.28.0   000     x     +     0100   -    1011
//  K.28.1   100     1     +     1001   0    0110     ! Singular Comma
//  K.28.2   010     1     +     0101   0    1010     !
//  K.28.3   110     x     -     1100   0    0011     !
//  K.28.4   001     x     +     0010   -    1101     !
//  K.28.5   101     1     +     1010   0    0101     ! Singular Comma
//  K.28.6   011     1     +     0110   0    1001     !
//  K.28.7   111     x     -     0111   +    1000       Singular Comma
//
//  K.23.7   111     x     -     0111   +    1000
//  K.27.7   111     x     -     0111   +    1000
//  K.29.7   111     x     -     0111   +    1000
//  K.30.7   111     x     -     0111   +    1000
//
// The alternate Data encoding D.x.A7 is used in the case
//   that e = i = 1 and negative running disparity,
//   or   e = i = 0 and positive running disparity,
//   or a Control signal is being sent,
//   all while encoding 7 in the MSB.
//
// This exception to the simple rule guarantees that there
//   aren't a run of 5 1's or 5 0's in the first 6 bits
//   concatinated with the last 4 bits.
//
// The special sequence starting at "a" of 2 0's followed by
//   5 1's, or 2 1's followed by 5 0's, is called a
//   "Singular Comma".
// A Singular Comma does not occur in any valid code EXCEPT
//   K.28.1 or K.28.5 or K.28.7. 
 
// Accumulate the new data.  First, calculate ignoring the running disparity;
  wire   [9:0] first_level_encoded_data;

// Calculate the values for the 3 -> 4 encoding

// Notice that the bottom bit of the encoded LSB data is the same as
//   the input LSB data.
  assign  first_level_encoded_data[0] = eight_bit_data_or_control_in[0];

// As can be seen, in many of the LSB encodings the bottom
//   4 of the encoded data are identical to the input
//   data.  (These are noted with a trailing "!")
//
// There are 3 exceptions to this in the LSB.  Decode these.
  wire    LSB_all_zero = (eight_bit_data_or_control_in[3:0] == 4'h0);
  wire    LSB_is_24    = (eight_bit_data_or_control_in[4:0] == 5'h18);  // 24
  wire    LSB_all_one  = (eight_bit_data_or_control_in[3:0] == 4'hF);

// If the bottom 4 bits are 0s, force 0110 (LSB is the left bit)
// If the bottom 5 bits are 24, force 0011 (LSB is the left bit)
// If the bottom 4 bits are 1s, force 1010 (LSB is the left bit)
  assign  first_level_encoded_data[1] = (   eight_bit_data_or_control_in[1]
                                          & ~LSB_all_one)
                                      | LSB_all_zero;
  assign  first_level_encoded_data[2] = eight_bit_data_or_control_in[2]
                                      | LSB_all_zero
                                      | LSB_is_24;
  assign  first_level_encoded_data[3] = (   eight_bit_data_or_control_in[3]
                                          & ~LSB_all_one);

// Bits "e" and "i" are chosen to guarantee that there are enough transitions,
//   and to control the disparity caused by each pattern.
  wire    LSB_contains_one_one = (eight_bit_data_or_control_in[3:0] == 4'h1)
                               | (eight_bit_data_or_control_in[3:0] == 4'h2)
                               | (eight_bit_data_or_control_in[3:0] == 4'h4)
                               | (eight_bit_data_or_control_in[3:0] == 4'h8);

  wire    LSB_contains_two_ones = (eight_bit_data_or_control_in[3:0] == 4'h3)
                                | (eight_bit_data_or_control_in[3:0] == 4'h5)
                                | (eight_bit_data_or_control_in[3:0] == 4'h9)
                                | (eight_bit_data_or_control_in[3:0] == 4'h6)
                                | (eight_bit_data_or_control_in[3:0] == 4'hA)
                                | (eight_bit_data_or_control_in[3:0] == 4'hC);

  wire    LSB_contains_three_ones = (eight_bit_data_or_control_in[3:0] == 4'h7)  // 23
                                  | (eight_bit_data_or_control_in[3:0] == 4'hB)  // 27
                                  | (eight_bit_data_or_control_in[3:0] == 4'hD)  // 29
                                  | (eight_bit_data_or_control_in[3:0] == 4'hE);  // 30

  wire    LSB_contains_other_i = (eight_bit_data_or_control_in[3:0] == 4'h0)
                               | (eight_bit_data_or_control_in[3:0] == 4'h1)
                               | (eight_bit_data_or_control_in[3:0] == 4'h2)
                               | (eight_bit_data_or_control_in[3:0] == 4'h4);

  wire    LSB_is_28    = (eight_bit_data_or_control_in[4:0] == 5'h1C);  // 28

  assign  first_level_encoded_data[4] = (   LSB_contains_one_one
                                          | eight_bit_data_or_control_in[4])
                                      & ~LSB_is_24;

  assign  first_level_encoded_data[5] =
                    (LSB_contains_two_ones & ~eight_bit_data_or_control_in[4])
                  | (   (  LSB_contains_other_i | LSB_all_one)
                      & eight_bit_data_or_control_in[4])
                  | (input_is_control & LSB_is_28);

// Now calculate the other information needed to produce the LSB output data
  wire    LSB_term_has_positive_disparity =
                | (   (   LSB_all_zero
                        | LSB_contains_three_ones
                        | LSB_all_one)
                    & (eight_bit_data_or_control_in[4] == 1'b1))
                | input_is_control;

  wire    LSB_term_has_negative_disparity =
                    (   LSB_all_zero
                      | LSB_contains_one_one
                      | LSB_all_one)
                    & (eight_bit_data_or_control_in[4] == 1'b0);

  wire    invert_LSB_if_input_disparity_is_positive =
                  LSB_term_has_positive_disparity
                | (eight_bit_data_or_control_in[4:0] == 5'h07);  // 7

  wire    invert_LSB_if_input_disparity_is_negative =
                    LSB_term_has_negative_disparity
                  | (eight_bit_data_or_control_in[3:0] == 4'h8);  // 24

  wire    LSB_toggle_running_disparity =
                  LSB_term_has_positive_disparity
                | invert_LSB_if_input_disparity_is_negative;

// Calculate the values for the 3 -> 4 encoding

// An alternate encoding of the MSB for an input of 0x7 is used to
//   prevent accidental use of a pattern with 5 0's or 1's in a row.
// The alternate Data encoding D.x.A7 is used in the case
//   that e = i = 0 and positive running disparity,
//   or   e = i = 1 and negative running disparity,
//   or a Control signal is being sent,
//   all while encoding 7 in the MSB.

  reg     Running_Disparity;  // forward reference

  wire    use_alternate_encoding = (   input_is_control
                                     | (   (Running_Disparity == 1'b0)
                                         & (   (eight_bit_data_or_control_in[4:0] == 5'h11)  // 17
                                             | (eight_bit_data_or_control_in[4:0] == 5'h12)  // 18
                                             | (eight_bit_data_or_control_in[4:0] == 5'h14)  // 20
                                       ))
                                     | (   (Running_Disparity == 1'b1)
                                         & (   (eight_bit_data_or_control_in[4:0] == 5'h0B)  // 11
                                             | (eight_bit_data_or_control_in[4:0] == 5'h0D)  // 13
                                             | (eight_bit_data_or_control_in[4:0] == 5'h0E)  // 14
                                       ))
                                     )
                                 & (eight_bit_data_or_control_in[7:5] == 3'h7);

// The low bit of the MSB is a pass-through, except when the alternate
//   encoding of the value is used to prevent unintentional long runs.
  assign  first_level_encoded_data[6] = eight_bit_data_or_control_in[5]
                                      & ~use_alternate_encoding;

// The second bit of the MSB is a pass-through except when the input
//   is all 0's.
  wire    MSB_all_zero = (eight_bit_data_or_control_in[7] == 1'h0)
                       & (eight_bit_data_or_control_in[5] == 1'h0);

  assign  first_level_encoded_data[7] = eight_bit_data_or_control_in[6]
                                      | MSB_all_zero;

// The top bit of the encoded MSB data is the same as the input MSB data.
  assign  first_level_encoded_data[8] = eight_bit_data_or_control_in[7];

// Bit "j" is chosen to guarantee that there are enough transitions,
//   and to control the disparity caused by each pattern.
  assign  first_level_encoded_data[9] =
                  (eight_bit_data_or_control_in[7:5] == 3'h1)
                | (eight_bit_data_or_control_in[7:5] == 3'h2)
                | use_alternate_encoding;

// Now calculate the other information needed to produce the MSB output data
  wire    invert_MSB_if_LSB_disparity_is_positive =
                  (eight_bit_data_or_control_in[7:5] == 3'h3)
                | (eight_bit_data_or_control_in[7:5] == 3'h7);

  wire    invert_MSB_if_LSB_disparity_is_negative =
                  (eight_bit_data_or_control_in[7:5] == 3'h0)
                | (eight_bit_data_or_control_in[7:5] == 3'h4)
                | (   input_is_control
                    & (   (eight_bit_data_or_control_in[7:5] == 3'h1)
                        | (eight_bit_data_or_control_in[7:5] == 3'h2)
                        | (eight_bit_data_or_control_in[7:5] == 3'h5)
                        | (eight_bit_data_or_control_in[7:5] == 3'h6) ));

  wire    MSB_toggle_running_disparity =
                  (eight_bit_data_or_control_in[7:5] == 3'h0)
                | (eight_bit_data_or_control_in[7:5] == 3'h4)
                | (eight_bit_data_or_control_in[7:5] == 3'h7);

// Keep track of the running disparity.  If 1'b1, the disparity is positive.
  always @(posedge clk)
  begin
    if (reset == 1'b1)
    begin
      Running_Disparity <= 1'b0;  // start negative
    end
    else
    begin
      Running_Disparity <= Running_Disparity
                         ^ LSB_toggle_running_disparity
                         ^ MSB_toggle_running_disparity;
    end
  end

// disparity_from_LSB

// Decide whether to invert the encoded data;
  wire    Invert_LSB = (   (Running_Disparity == 1'b1)
                         & (invert_LSB_if_input_disparity_is_positive == 1'b1) )
                     | (   (Running_Disparity == 1'b0)
                         & (invert_LSB_if_input_disparity_is_negative == 1'b1) );

  wire    Invert_MSB = (   ((Running_Disparity ^ LSB_toggle_running_disparity) == 1'b1)
                         & (invert_MSB_if_LSB_disparity_is_positive == 1'b1) )
                     | (   ((Running_Disparity ^ LSB_toggle_running_disparity) == 1'b0)
                         & (invert_MSB_if_LSB_disparity_is_negative == 1'b1) );

// Calculate the actual encoded data.
  reg    [9:0] ten_bit_encoded_data_out;
  reg     invalid_control;

  always @(posedge clk)
  begin
    if (reset == 1'b1)
    begin
      ten_bit_encoded_data_out[9:0] <= 10'h000;
      invalid_control <= 1'b0;
    end
    else
    begin
      ten_bit_encoded_data_out[5:0] <=
                  {6{Invert_LSB}} ^ first_level_encoded_data[5:0];
      ten_bit_encoded_data_out[9:6] <=
                  {4{Invert_MSB}} ^ first_level_encoded_data[9:6];
      invalid_control <= input_is_control
                & ~(   LSB_is_28  // all MSB bits are valid
                     | (   (   (eight_bit_data_or_control_in[4:0] == 5'h17)  // 23
                             | (eight_bit_data_or_control_in[4:0] == 5'h1B)  // 27
                             | (eight_bit_data_or_control_in[4:0] == 5'h1D)  // 29
                             | (eight_bit_data_or_control_in[4:0] == 5'h1E)  // 30
                           )
                         & (eight_bit_data_or_control_in[7:5] == 3'h7)  // MSB must be 7
                   ) );
    end
  end

// synopsys translate_off
  initial
  begin
/*
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
 */
  end
// synopsys translate_on
endmodule

// Convert 10-bit code to 8-bit binary or 8-bit control code

module decode_10b_8b (
  ten_bit_encoded_data_in,
  eight_bit_data_or_control_out,
  output_is_control,
  invalid_encoded_data,
  clk,
  reset
);
  input  [9:0] ten_bit_encoded_data_in;
  output [7:0] eight_bit_data_or_control_out;
  output  output_is_control;
  output  invalid_encoded_data;
  input   clk, reset;

// Data is encoded as described in the encode_8b_10b module above.
// This module tries to extract valid data or control info from the
//   encoded input data.
//
// This module depends on the data being correctly 10-bit aligned.
//  the LSB of the input must be the "a" bit as described above.
//
// This module tries to detect errors in the code sequence as it arrives.
// Errors are when an illegal bit sequence arrives, or when the disparity
//   of the input data goes beyond 1 bit.  This would happen if the sender
//   did not correctly use alternate encodings of output data.

  wire   [1:0] LSB_02_Population = ten_bit_encoded_data_in[0]  // full adder
                                 + ten_bit_encoded_data_in[1]
                                 + ten_bit_encoded_data_in[2];
  wire   [1:0] LSB_35_Population = ten_bit_encoded_data_in[3]  // full adder
                                 + ten_bit_encoded_data_in[4]
                                 + ten_bit_encoded_data_in[5];

  wire   [2:0] LSB_Population = {1'b0, LSB_02_Population[1:0]}  // allowed: 2, 3, 4
                              + {1'b0, LSB_35_Population[1:0]};

  wire   [1:0] MSB_67_Population = ten_bit_encoded_data_in[6]  // full adder
                                 + ten_bit_encoded_data_in[7];
  wire   [1:0] MSB_89_Population = ten_bit_encoded_data_in[8]  // full adder
                                 + ten_bit_encoded_data_in[9];

  wire   [2:0] MSB_Population = {1'b0, MSB_67_Population[1:0]}  // allowed: 1, 2, 3
                              + {1'b0, MSB_89_Population[1:0]};

// From the table in the encode function, we see that the following "abcdei"
//   values are illegal:  (NOTE LSB TO LEFT)
//
//  000000  (population 0)
//  100000 010000 001000 000100 000010 000001  (population 1)
//  111100 000011  (could result in unintended run of 5 identical values)
//  111110 111101 111011 110111 101111 011111  (population 5)
//  111111  (population 6)
//
// We see that the following "fghj" values are illegal:  (NOTE LSB TO LEFT)
//
//  0000, 1111  (populations 0 and 4)
//
// We know that singular commas can only contain a string of 5 like values
//   at "c=d=e=i=f", so 

// The Xilinx Ap note says these are errors:
//  too large or small disparity, a=b=c=d, P13e'i', p31e'i, f=g=h=j,
//  e=i=f=g=h, i!=e=g=h=j, (e=i!=g=h=j)*(c=d=e)', P31ei'g'h'j', P13e'ighj,
//  non-alternating disparity, data must follow rules

// Keep track of the running disparity.  If 1'b1, the disparity is positive.
  reg     Running_Disparity;

  always @(posedge clk)
  begin
    if (reset == 1'b1)
    begin
      Running_Disparity <= 1'b0;  // start negative
    end
    else
    begin
      Running_Disparity <= Running_Disparity;
    end
  end

// Calculate the actual decoded data.
  reg    [7:0] eight_bit_data_or_control_out;
  reg     output_is_control;
  reg     invalid_encoded_data;

  always @(posedge clk)
  begin
    if (reset == 1'b1)
    begin
      eight_bit_data_or_control_out[7:0] <= 8'h00;
      output_is_control <= 1'b0;
      invalid_encoded_data <= 1'b0;
    end
    else
    begin
      eight_bit_data_or_control_out[7:0] <= 8'h00;
      output_is_control <= 1'b0;
      invalid_encoded_data <= 1'b0;

    end
  end

endmodule

// `define TEST_8B_10B
`ifdef TEST_8B_10B
module test_8b_10b;
  reg    [8:0] test_data;
  reg     test_control;

// development code
  wire   [7:0] eight_bit_data_or_control_in = test_data[7:0];

  wire   [9:0] first_level_encoded_data;
  reg     input_is_control;

  wire    LSB_all_zero = (eight_bit_data_or_control_in[3:0] == 4'h0);
  wire    LSB_is_24    = (eight_bit_data_or_control_in[4:0] == 5'h18);
  wire    LSB_all_one  = (eight_bit_data_or_control_in[3:0] == 4'hF);

  assign  first_level_encoded_data[0] = eight_bit_data_or_control_in[0];
  assign  first_level_encoded_data[1] = (   eight_bit_data_or_control_in[1]
                                          & ~LSB_all_one)
                                      | LSB_all_zero;
  assign  first_level_encoded_data[2] = eight_bit_data_or_control_in[2]
                                      | LSB_all_zero
                                      | LSB_is_24;
  assign  first_level_encoded_data[3] = (   eight_bit_data_or_control_in[3]
                                          & ~LSB_all_one);

  wire    LSB_contains_one_one = (eight_bit_data_or_control_in[3:0] == 4'h1)
                               | (eight_bit_data_or_control_in[3:0] == 4'h2)
                               | (eight_bit_data_or_control_in[3:0] == 4'h4)
                               | (eight_bit_data_or_control_in[3:0] == 4'h8);

  wire    LSB_contains_two_ones = (eight_bit_data_or_control_in[3:0] == 4'h3)
                                | (eight_bit_data_or_control_in[3:0] == 4'h5)
                                | (eight_bit_data_or_control_in[3:0] == 4'h9)
                                | (eight_bit_data_or_control_in[3:0] == 4'h6)
                                | (eight_bit_data_or_control_in[3:0] == 4'hA)
                                | (eight_bit_data_or_control_in[3:0] == 4'hC);

  wire    LSB_contains_three_ones = (eight_bit_data_or_control_in[3:0] == 4'h7)  // 23
                                  | (eight_bit_data_or_control_in[3:0] == 4'hB)  // 27
                                  | (eight_bit_data_or_control_in[3:0] == 4'hD)  // 29
                                  | (eight_bit_data_or_control_in[3:0] == 4'hE);  // 30

  wire    LSB_contains_other_i = (eight_bit_data_or_control_in[3:0] == 4'h0)
                               | (eight_bit_data_or_control_in[3:0] == 4'h1)
                               | (eight_bit_data_or_control_in[3:0] == 4'h2)
                               | (eight_bit_data_or_control_in[3:0] == 4'h4);

  wire    LSB_is_28    = (eight_bit_data_or_control_in[4:0] == 5'h1C);  // 28

  assign  first_level_encoded_data[4] = (   LSB_contains_one_one
                                          | eight_bit_data_or_control_in[4])
                                      & ~LSB_is_24;

  assign  first_level_encoded_data[5] =
                    (LSB_contains_two_ones & ~eight_bit_data_or_control_in[4])
                  | (   (  LSB_contains_other_i | LSB_all_one)
                      & eight_bit_data_or_control_in[4])
                  | (input_is_control & LSB_is_28);

  wire    LSB_term_has_positive_disparity =
                | (   (   LSB_all_zero
                        | LSB_contains_three_ones
                        | LSB_all_one)
                    & (eight_bit_data_or_control_in[4] == 1'b1))
                | input_is_control;

  wire    LSB_term_has_negative_disparity =
                    (   LSB_all_zero
                      | LSB_contains_one_one
                      | LSB_all_one)
                    & (eight_bit_data_or_control_in[4] == 1'b0);

  wire    invert_LSB_if_input_disparity_is_positive =
                  LSB_term_has_positive_disparity
                | (eight_bit_data_or_control_in[4:0] == 5'h07);  // 7

  wire    invert_LSB_if_input_disparity_is_negative =
                    LSB_term_has_negative_disparity
                  | (eight_bit_data_or_control_in[3:0] == 4'h8);  // 24

  wire    LSB_toggle_running_disparity =
                  LSB_term_has_positive_disparity
                | invert_LSB_if_input_disparity_is_negative;

  wire    use_alternate_encoding = (   input_is_control
                                     | (1'b0) )  // NOTE WRONG
                                 & (eight_bit_data_or_control_in[7:5] == 3'h7);

// The alternate Data encoding D.x.A7 is used in the case
//   that e = i = 1 and negative running disparity,
//   or   e = i = 0 and positive running disparity,
//   or a Control signal is being sent encoding 7 in the MSB.

  assign  first_level_encoded_data[6] = eight_bit_data_or_control_in[5]
                                      & ~use_alternate_encoding;

// The second bit of the MSB is a pass-through except when the input
//   is all 0's.

  wire    MSB_all_zero = (eight_bit_data_or_control_in[7] == 1'h0)
                       & (eight_bit_data_or_control_in[5] == 1'h0);

  assign  first_level_encoded_data[7] = eight_bit_data_or_control_in[6]
                                      | MSB_all_zero;

// Notice that the top bit of the encoded MSB data is the same as
//   the input MSB data.
  assign  first_level_encoded_data[8] = eight_bit_data_or_control_in[7];

// Bit "j" is chosen to guarantee that there are enough transitions,
//   and to control the disparity caused by each pattern.

  assign  first_level_encoded_data[9] =
                  (eight_bit_data_or_control_in[7:5] == 3'h1)
                | (eight_bit_data_or_control_in[7:5] == 3'h2)
                | use_alternate_encoding;

  wire    invert_MSB_if_LSB_disparity_is_positive =
                  (eight_bit_data_or_control_in[7:5] == 3'h3)
                | (eight_bit_data_or_control_in[7:5] == 3'h7);

  wire    invert_MSB_if_LSB_disparity_is_negative =
                  (eight_bit_data_or_control_in[7:5] == 3'h0)
                | (eight_bit_data_or_control_in[7:5] == 3'h4)
                | (   input_is_control
                    & (   (eight_bit_data_or_control_in[7:5] == 3'h1)
                        | (eight_bit_data_or_control_in[7:5] == 3'h2)
                        | (eight_bit_data_or_control_in[7:5] == 3'h5)
                        | (eight_bit_data_or_control_in[7:5] == 3'h6) ));

  wire    MSB_toggle_running_disparity =
                  (eight_bit_data_or_control_in[7:5] == 3'h0)
                | (eight_bit_data_or_control_in[7:5] == 3'h4)
                | (eight_bit_data_or_control_in[7:5] == 3'h7);

  initial
  begin
    input_is_control = 1'b0;
    for (test_data = 9'h000; test_data < 9'h020; test_data = test_data + 9'h001)
    begin
      # 0; $display ("test data, result %x %b %b %b %b %b", test_data[7:0],
                         first_level_encoded_data[9:6], first_level_encoded_data[5:0],
                         invert_LSB_if_input_disparity_is_positive,
                         invert_LSB_if_input_disparity_is_negative,
                         LSB_toggle_running_disparity);
    end

    input_is_control = 1'b1;
    test_data = 23;
      # 0; $display ("test data, result %x %b %b %b %b",
                         test_data[7:0], first_level_encoded_data[5:0],
                         invert_LSB_if_input_disparity_is_positive,
                         invert_LSB_if_input_disparity_is_negative,
                         LSB_toggle_running_disparity);
    for (test_data = 27; test_data < 31; test_data = test_data + 9'h001)
    begin
      # 0; $display ("test data, result %x %b %b %b %b",
                         test_data[7:0], first_level_encoded_data[5:0],
                         invert_LSB_if_input_disparity_is_positive,
                         invert_LSB_if_input_disparity_is_negative,
                         LSB_toggle_running_disparity);
    end

    input_is_control = 1'b0;
    for (test_data = 9'h000 + 28; test_data < 9'h100; test_data = test_data + 9'h020)
    begin
      # 0; $display ("test data, result %x %b %b %b %b",
                         test_data[7:0], first_level_encoded_data[9:6],
                         invert_MSB_if_LSB_disparity_is_positive,
                         invert_MSB_if_LSB_disparity_is_negative,
                         MSB_toggle_running_disparity);
    end
    input_is_control = 1'b1;
    for (test_data = 9'h000 + 28; test_data < 9'h100; test_data = test_data + 9'h020)
    begin
      # 0; $display ("test data, result %x %b %b %b %b",
                         test_data[7:0], first_level_encoded_data[9:6],
                         invert_MSB_if_LSB_disparity_is_positive,
                         invert_MSB_if_LSB_disparity_is_negative,
                         MSB_toggle_running_disparity);
    end
  end

  wire   [9:0] ten_bit_encoded_data_out;

encode_8b_10b encode_8b_10b (
  .eight_bit_data_or_control_in (eight_bit_data_or_control_in[7:0]),
  .input_is_control           (input_is_control),
  .ten_bit_encoded_data_out   (ten_bit_encoded_data_out[9:0]),
  .invalid_control            (invalid_control),
  .clk                        (clk),
  .reset                      (reset)
);


  wire   [9:0] ten_bit_encoded_data_in;
  wire   [7:0] eight_bit_data_or_control_out;

decode_10b_8b decode_10b_8b (
  .ten_bit_encoded_data_in    (ten_bit_encoded_data_in[9:0]),
  .eight_bit_data_or_control_out (eight_bit_data_or_control_out[7:0]),
  .output_is_control          (output_is_control),
  .invalid_encoded_data       (invalid_encoded_data),
  .clk                        (clk),
  .reset                      (reset)

);
endmodule
`endif  // TEST_8B_10B

module figure_out_error_patterns;
  reg    [10:0] i;

  reg    [9:0] full_addr; 
  reg    [4095:0] mask;  // storage

task do_one;
  input  [3:0] high_addr;
  begin
    full_addr[3:0] = high_addr[3:0];  // note LSB to left
    mask[full_addr[9:0]] = 1'b1;
  end
endtask

task test_both;
  begin
// both
    do_one (4'b1001);
    do_one (4'b0101);
    do_one (4'b1010);
    do_one (4'b0110);
  end
endtask

// The alternate Data encoding D.x.A7 is used in the case
//   that e = i = 0 and positive running disparity,
//   or   e = i = 1 and negative running disparity,
//   or a Control signal is being sent,
//   all while encoding 7 in the MSB.

task test_positive;
  begin
// positive list
    do_one (4'b0100);
    do_one (4'b0011);
    do_one (4'b0010);
    if (full_addr[5:4] != 2'b00)
      do_one (4'b0001);  // P
    else
      do_one (4'b1000);  // A
  end
endtask

task test_negative;
  begin
// negative list
    do_one (4'b1011);
    do_one (4'b1100);
    do_one (4'b1101);
    if (full_addr[5:4] != 2'b11)
      do_one (4'b1110);  // P
    else
      do_one (4'b0111);  // A
  end
endtask

task test_all;
  begin
    test_positive;
    test_negative;
    test_both;
  end
endtask

task test;
  input  [5:0] val;
  input   type;
  integer type;

  begin
    full_addr[9:4] = val[5:0];  // note LSB to left
    if (type == 0)
    begin
      test_all;
    end
    else if (type == 1)
    begin
      test_positive;
      test_both;
    end
    else
    begin
      test_negative;
      test_both;
    end
  end
endtask

initial
  begin

// Clear all bits
    for (i[10:0] = 11'h000; i[10:0] < 11'h400; i[10:0] = i[10:0] + 11'h001)
    begin
      mask[i[9:0]] = 1'b0;
    end

// Mark bits which are parts of valid codes
    test (6'b110001, 0);
    test (6'b101001, 0);
    test (6'b011001, 0);
    test (6'b100101, 0);
    test (6'b010101, 0);
    test (6'b110100, 0);
    test (6'b001101, 0);
    test (6'b101100, 0);
    test (6'b011100, 0);
    test (6'b100011, 0);
    test (6'b010011, 0);
    test (6'b110010, 0);
    test (6'b001011, 0);
    test (6'b101010, 0);
    test (6'b011010, 0);
    test (6'b100110, 0);
    test (6'b010110, 0);
    test (6'b001110, 0);

    test (6'b011000, -1);
    test (6'b100010, -1);
    test (6'b010010, -1);
    test (6'b001010, -1);
    test (6'b111000, -1);
    test (6'b000110, -1);
    test (6'b101000, -1);
    test (6'b100100, -1);
    test (6'b000101, -1);
    test (6'b001100, -1);
    test (6'b001001, -1);
    test (6'b010001, -1);
    test (6'b100001, -1);
    test (6'b010100, -1);

    test (6'b100111, +1);
    test (6'b011101, +1);
    test (6'b101101, +1);
    test (6'b110101, +1);
    test (6'b000111, +1);
    test (6'b111001, +1);
    test (6'b010111, +1);
    test (6'b011011, +1);
    test (6'b111010, +1);
    test (6'b110011, +1);
    test (6'b110110, +1);
    test (6'b101110, +1);
    test (6'b011110, +1);
    test (6'b101011, +1);

    for (i[10:0] = 11'h000; i[10:0] < 11'h400; i[10:0] = i[10:0] + 11'h001)
    begin
// Get rid of patterns in the 6 LSB with less than 2 or greater than 4 bits set.
      if ((i[9] + i[8] + i[7] + i[6] + i[5] + i[4]) < 2)
      begin
        mask[i[9:0]] = 1'b1;
      end
      if ((i[9] + i[8] + i[7] + i[6] + i[5] + i[4]) > 4)
      begin
        mask[i[9:0]] = 1'b1;
      end
// Get rid of patterns in the 4 MSB with less than 1 or greater than 3 bits set.
      if ((i[3:0] == 4'h0) | (i[3:0] == 4'hF))
      begin
        mask[i[9:0]] = 1'b1;
      end
// Get rid of total patterns with less than 4 or greater than 6 bits set.
      if ((i[0] + i[1] + i[2] + i[3] + i[4] + i[5] + i[6] + i[7] + i[8] + i[9]) < 4)
      begin
        mask[i[9:0]] = 1'b1;
      end
      if ((i[0] + i[1] + i[2] + i[3] + i[4] + i[5] + i[6] + i[7] + i[8] + i[9]) > 6)
      begin
        mask[i[9:0]] = 1'b1;
      end
// Get rid of patterns with the 4 LSB all 0 or all 1
      if ((i[9:6] == 4'b0000) | (i[9:6] == 4'b1111))
      begin
        mask[i[9:0]] = 1'b1;
      end
// Get rid of patterns which use D.7.y with the wrong disparity.
      if ((i[9:4] == 6'b111000) & (i[3] + i[2] + i[1] + i[0] == 1))  // minus then minus
      begin
        mask[i[9:0]] = 1'b1;
      end
      if ((i[9:4] == 6'b000111) & (i[3] + i[2] + i[1] + i[0] == 3))  // plus then plus
      begin
        mask[i[9:0]] = 1'b1;
      end
// Get rid of patterns which use D.x.3 with the wrong disparity.
      if (   (i[3:0] == 4'b0011)
           & ((i[9] + i[8] + i[7] + i[6] + i[5] + i[4]) == 2))
      begin
        mask[i[9:0]] = 1'b1;
      end
      if (   (i[3:0] == 4'b1100)
           & ((i[9] + i[8] + i[7] + i[6] + i[5] + i[4]) == 4))
      begin
        mask[i[9:0]] = 1'b1;
      end
// Get rid of non-control codes which use alternate encoding inappropriately.
// These are all the data items except 23, 27, 29, and 39 which do not end in
//   00 or 11 as the MSB.  This excludes control codes, which use alternate encoding.
      if (   (i[9:4] != 6'b111010) & (i[9:4] != 6'b000101)  // 23
           & (i[9:4] != 6'b110110) & (i[9:4] != 6'b001001)  // 27
           & (i[9:4] != 6'b101110) & (i[9:4] != 6'b010001)  // 29
           & (i[9:4] != 6'b011110) & (i[9:4] != 6'b100001)  // 30
           & ((i[5:4] == 2'b01) | (i[5:4] == 2'b10)))
      begin
        if ((i[3:0] == 4'b0111) | (i[3:0] == 4'b1000))
        begin
          mask[i[9:0]] = 1'b1;
        end
      end
    end

// Get rid of case when D.x.3 and D.7.y are used together as D.7.3
    mask[10'b111000_0011] = 1'b1;
    mask[10'b000111_1100] = 1'b1;

// Get rid of case where LSB has 3 bits set, input disparity makes primary
//   or alternate code impossible.
    mask[10'b110100_0111] = 1'b1;  // negative in  11
    mask[10'b110100_0001] = 1'b1;  // positive in  11
    mask[10'b101100_0111] = 1'b1;  // negative in  13
    mask[10'b101100_0001] = 1'b1;  // positive in  13
    mask[10'b011100_0111] = 1'b1;  // negative in  14
    mask[10'b011100_0001] = 1'b1;  // positive in  14
    mask[10'b100011_1110] = 1'b1;  // negative in  17
    mask[10'b100011_1000] = 1'b1;  // positive in  17
    mask[10'b010011_1110] = 1'b1;  // negative in  18
    mask[10'b010011_1000] = 1'b1;  // positive in  18
    mask[10'b001011_1110] = 1'b1;  // negative in  20
    mask[10'b001011_1000] = 1'b1;  // positive in  20

    mask[10'b111000_0111] = 1'b1;  // negative in  7
    mask[10'b000111_1000] = 1'b1;  // positive in  7

// Get rid of case where LSB has 2 or 4 bits set, and choice of primary
//   or alternate code makes the other code impossible.
    mask[10'b001100_0111] = 1'b1;  // negative  24
    mask[10'b110011_1000] = 1'b1;  // positive  24
//    mask[10'b001110_0111] = 1'b1;  // negative  28
  //  mask[10'b001110_1000] = 1'b1;  // positive  28
    mask[10'b010100_0111] = 1'b1;  // negative  31
    mask[10'b101011_1000] = 1'b1;  // positive  31
    mask[10'b101000_0111] = 1'b1;  // negative  15
    mask[10'b010111_1000] = 1'b1;  // positive  15
    mask[10'b011000_0111] = 1'b1;  // negative  0
    mask[10'b100111_1000] = 1'b1;  // positive  0
    mask[10'b100100_0111] = 1'b1;  // negative  16
    mask[10'b011011_1000] = 1'b1;  // positive  16


    mask[10'b001111_0001] = 1'b1;  // positive  K28
    mask[10'b110000_1110] = 1'b1;  // negative  K28


// get rid of the control codes.
    mask[10'b111010_1000] = 1'b1;
    mask[10'b110110_1000] = 1'b1;
    mask[10'b101110_1000] = 1'b1;
    mask[10'b011110_1000] = 1'b1;

    mask[10'b001111_0100] = 1'b1;
    mask[10'b001111_1001] = 1'b1;
    mask[10'b001111_0101] = 1'b1;
    mask[10'b001111_0011] = 1'b1;
    mask[10'b001111_0010] = 1'b1;
    mask[10'b001111_1010] = 1'b1;
    mask[10'b001111_0110] = 1'b1;
    mask[10'b001111_1000] = 1'b1;

    mask[~10'b111010_1000] = 1'b1;
    mask[~10'b110110_1000] = 1'b1;
    mask[~10'b101110_1000] = 1'b1;
    mask[~10'b011110_1000] = 1'b1;

    mask[~10'b001111_0100] = 1'b1;
    mask[~10'b001111_1001] = 1'b1;
    mask[~10'b001111_0101] = 1'b1;
    mask[~10'b001111_0011] = 1'b1;
    mask[~10'b001111_0010] = 1'b1;
    mask[~10'b001111_1010] = 1'b1;
    mask[~10'b001111_0110] = 1'b1;
    mask[~10'b001111_1000] = 1'b1;

// The Xilinx Ap note says these are errors:
//  too large or small disparity, a=b=c=d, P13e'i', p31e'i, f=g=h=j,
//  e=i=f=g=h, i!=e=g=h=j, (e=i!=g=h=j)*(c=d=e)', P31ei'g'h'j', P13e'ighj,
//  non-alternating disparity, data must follow rules

    $display ("LSB is to the left");
    for (i[10:0] = 11'h000; i[10:0] < 11'h400; i[10:0] = i[10:0] + 11'h001)
    begin
      if (mask[i[9:0]] !== 1'b1)
      begin
        $display ("not set %b", i[9:0]);
      end
    end

  end
endmodule

