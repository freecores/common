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
////    The IBM Patent grew up in a world where the Least         ////
////    Significant Bit of a word was written to the Left.        ////
////    These modules use the LSB as Bit 0, and it will           ////
////    typically be written as the Rightmost bit in a field.     ////
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
// $Id: encode_8b_10b.v,v 1.6 2001-11-29 09:22:08 bbeaver Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.19  2001/11/29 09:31:11  Blue Beaver
// no message
//
// Revision 1.18  2001/10/26 10:39:43  Blue Beaver
// no message
//
// Revision 1.17  2001/10/26 10:38:05  Blue Beaver
// no message
//
// Revision 1.16  2001/10/25 11:43:03  Blue Beaver
// no message
//
// Revision 1.14  2001/10/25 11:33:51  Blue Beaver
// no message
//
// Revision 1.13  2001/10/24 11:38:02  Blue Beaver
// no message
//
// Revision 1.12  2001/10/24 09:47:40  Blue Beaver
// no message
//
// Revision 1.11  2001/10/24 08:49:02  Blue Beaver
// no message
//
// Revision 1.10  2001/10/24 07:28:08  Blue Beaver
// no message
//
// Revision 1.9  2001/10/23 10:34:50  Blue Beaver
// no message
//
// Revision 1.8  2001/10/23 08:12:37  Blue Beaver
// no message
//
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
  mess_up_link_disparity,
  ten_bit_encoded_data_out,
  invalid_control,
  clk,
  reset
);

  input  [7:0] eight_bit_data_or_control_in;
  input   input_is_control;
  input   mess_up_link_disparity;
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
//
// The web says K.28.5 is the Fiber Channel Comma Character.
//
// NOTE that K.28.7 is a bad comma character, because it
//   can be followed by a FALSE comma character when followed
//   by any character starting with 2 1's or 0's, like K.11
// The false comma character is part in the K.28.7 and part
//   in the following data byte.  Bad.
//
// The following info is found in www.wildpackets.com/compendium/GB/L1-GbEn.html,
//   in a document headed:
// "Gigabit Ethernet is Closely Related to Fibre Channel Technology,
//    going back to 1988!"
//
// 8B-10B characters are described as Dn.m, where n gives the low order
//    5 bits in decimal, and m gives the top 3 bits.
//
// Configuration data is transferred as an alternating sequence of:
// (flips disparity: "C1") K28.5/D21.5/Config_reg[7:0]/Config_reg[15:8]
// (leaves disparity: "C2") K28.5/D2.2/Config_reg[7:0]/Config_reg[15:8]
//
// Idle status is transmitted when ther eis nothing else to send.
// The link is left in negative disparity.  If it is positive, first
// "I1" K28.5/D5.6 is sent, which knocks the displarity to negative
// "I2" K28.5/D16.2 is sent repeatitively to maintain the negative disparity
//
// Start of Packet delimiter "S" K27.7
// End of Packet delimiter "T" K29.7
// Carrier Extend "R" K23.7
//
// An End Of Packet consists of either T/R/I or T/R/R
// The second is used when a packet follows the previous packet in a burst.
// "R" is also sent so that a subsequent "I" follows on an even-numbered
//   code boundry.
//
// Error propagation "V"  K30.7


// Accumulate the new data.  First, calculate ignoring the running disparity;
  wire   [9:0] first_level_encoded_data;

// Calculate the values for the 5 -> 6 encoding

// Discover important details about the incoming numbers.
  wire   [1:0] LSB_02_Population = eight_bit_data_or_control_in[0]  // half adder
                                 + eight_bit_data_or_control_in[1];
  wire   [1:0] LSB_34_Population = eight_bit_data_or_control_in[2]  // half adder
                                 + eight_bit_data_or_control_in[3];
  wire   [2:0] LSB_Population = {1'b0, LSB_02_Population[1:0]}
                              + {1'b0, LSB_34_Population[1:0]};

// As can be seen, in many of the LSB encodings the bottom
//   4 of the encoded data are identical to the input
//   data.  (These are noted with a trailing "!")
//
// There are several exceptions to this in the LSB.  Decode these.
  wire    LSB_all_zero = (LSB_Population[2:0] == 3'h0);
  wire    LSB_contains_one_one = (LSB_Population[2:0] == 3'h1);
  wire    LSB_contains_two_ones = (LSB_Population[2:0] == 3'h2);
  wire    LSB_contains_three_ones = (LSB_Population[2:0] == 3'h3);
  wire    LSB_all_one  = (LSB_Population[2:0] == 3'h4);

  wire    LSB_is_7     = (eight_bit_data_or_control_in[4:0] == 5'h07);  // 7
  wire    LSB_is_24    = (eight_bit_data_or_control_in[4:0] == 5'h18);  // 24
  wire    LSB_is_28    = (eight_bit_data_or_control_in[4:0] == 5'h1C);  // 28
  wire    LSB_is_23_27_29_30 = (eight_bit_data_or_control_in[4:0] == 5'h17)  // 23
                             | (eight_bit_data_or_control_in[4:0] == 5'h1B)  // 27
                             | (eight_bit_data_or_control_in[4:0] == 5'h1D)  // 29
                             | (eight_bit_data_or_control_in[4:0] == 5'h1E);  // 30
  wire    LSB_contains_other_i = (eight_bit_data_or_control_in[3:0] == 4'h0)
                               | (eight_bit_data_or_control_in[3:0] == 4'h1)
                               | (eight_bit_data_or_control_in[3:0] == 4'h2)
                               | (eight_bit_data_or_control_in[3:0] == 4'h4);

// Notice that the bottom bit of the encoded LSB data is the same as
//   the input LSB data.
  assign  first_level_encoded_data[0] = eight_bit_data_or_control_in[0];

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

  assign  first_level_encoded_data[4] =
                  (LSB_contains_one_one | eight_bit_data_or_control_in[4])
                & ~LSB_is_24;

  assign  first_level_encoded_data[5] =
                  (LSB_contains_two_ones & ~eight_bit_data_or_control_in[4])
                | (   (  LSB_contains_other_i | LSB_all_one)
                    & eight_bit_data_or_control_in[4])
                | (input_is_control & LSB_is_28);

// Now calculate the other information needed to produce the LSB output data
  wire    LSB_code_has_positive_disparity =
                | (   (   LSB_all_zero
                        | LSB_contains_three_ones
                        | LSB_all_one)
                    & (eight_bit_data_or_control_in[4] == 1'b1) )
                | (input_is_control & LSB_is_28);

  wire    LSB_code_has_negative_disparity =
                  ( (   LSB_all_zero
                      | LSB_contains_one_one
                      | LSB_all_one)
                    & (eight_bit_data_or_control_in[4] == 1'b0) )
                | LSB_is_24;

  wire    invert_LSB_if_input_disparity_is_positive =
                  LSB_code_has_positive_disparity
                | LSB_is_7;

  wire    invert_LSB_if_input_disparity_is_negative =
                  LSB_code_has_negative_disparity;

  wire    LSB_toggle_running_disparity =
                  LSB_code_has_positive_disparity
                | LSB_code_has_negative_disparity;

// Calculate the values for the 3 -> 4 encoding

// An alternate encoding of the MSB for an input of 0x7 is used to
//   prevent accidental use of a pattern with 5 0's or 1's in a row.
// The alternate Data encoding D.x.A7 is used in the case
//   that e = i = 0 and positive running disparity,
//   or   e = i = 1 and negative running disparity,
//   or a Control signal is being sent,
//   all while encoding 7 in the MSB.

  reg     Running_Disparity;  // forward reference

  wire    use_alternate_encoding =
                  (   input_is_control
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
  assign  first_level_encoded_data[7] = eight_bit_data_or_control_in[6]
                                      | (eight_bit_data_or_control_in[7:5]  == 3'h0);

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
                        | (eight_bit_data_or_control_in[7:5] == 3'h6)
                       )
                  );

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
                     | (   LSB_is_23_27_29_30
                         & (eight_bit_data_or_control_in[7:5] == 3'h7)  // MSB must be 7
                        )
                   );
    end
  end
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

// Accumulate the new data.  Calculate ignoring the running disparity;
  wire   [7:0] decoded_data;

// Calculate the values for the 6 -> 5 decoding

// Discover important details about the incoming numbers.
  wire   [1:0] LSB_02_Population = ten_bit_encoded_data_in[0]  // full adder
                                 + ten_bit_encoded_data_in[1]
                                 + ten_bit_encoded_data_in[2];
  wire   [1:0] LSB_35_Population = ten_bit_encoded_data_in[3]  // full adder
                                 + ten_bit_encoded_data_in[4]
                                 + ten_bit_encoded_data_in[5];
  wire   [2:0] LSB_bottom_4_Population = {1'b0, LSB_02_Population[1:0]}
                                       + {2'b00, ten_bit_encoded_data_in[3]};
  wire   [2:0] LSB_Population = {1'b0, LSB_02_Population[1:0]}  // allowed: 2, 3, 4
                              + {1'b0, LSB_35_Population[1:0]};  // illegal: 0, 1, 5, 6

// As can be seen, in many of the LSB encodings the bottom
//   4 of the decoded data are identical to the input
//   data.  (These are noted with a trailing "!")
//
// The bottom 4 bits can be used directly in these cases (which are all cases
//   where the number of bits in the input are equil to 3 except for 7):
//   3 5 6 9 10 11 12 13 14 17 18 19 20 21 22 25 26 28

// The bottom 4 bits must be inverted before use in these cases:  (MSB right)
//   011101 101101 110101 111001 000101 001001 010001 100001 000111 110000
  wire    LSB_Invert_Before_Use = (   (ten_bit_encoded_data_in[5:4] == 2'b10)
                                    & (   (LSB_bottom_4_Population[2:0] == 3'h1)
                                        | (LSB_bottom_4_Population[2:0] == 3'h3) )
                                  )
                                | (ten_bit_encoded_data_in[5:0] == 6'b111000)  // LSB to right
                                | (ten_bit_encoded_data_in[5:0] == 6'b000011);

// Values must be substituted in these cases:
  wire    LSB_is_0_16_a  = (ten_bit_encoded_data_in[5:0] == 6'b000110)  // LSB to right
                         | (ten_bit_encoded_data_in[5:0] == 6'b110110);

  wire    LSB_is_0_16_b  = (ten_bit_encoded_data_in[5:0] == 6'b111001)  // LSB to right
                         | (ten_bit_encoded_data_in[5:0] == 6'b001001);

  wire    LSB_is_15_31_a = (ten_bit_encoded_data_in[5:0] == 6'b000101)  // LSB to right
                         | (ten_bit_encoded_data_in[5:0] == 6'b110101);

  wire    LSB_is_15_31_b = (ten_bit_encoded_data_in[5:0] == 6'b111010)  // LSB to right
                         | (ten_bit_encoded_data_in[5:0] == 6'b001010);

  wire    LSB_is_24_a    = (ten_bit_encoded_data_in[5:0] == 6'b001100);  // LSB to right
  wire    LSB_is_24_b    = (ten_bit_encoded_data_in[5:0] == 6'b110011);  // LSB to right

// Notice when these codes occur.  They are the only time Alternate D.x.7 data
//   can be used.  This is looked for below to detect errors.
  wire    LSB_is_11_13_14 = (ten_bit_encoded_data_in[5:0] == 6'b001011)  // LSB to right
                          | (ten_bit_encoded_data_in[5:0] == 6'b001101)
                          | (ten_bit_encoded_data_in[5:0] == 6'b001110);

  wire    LSB_is_17_18_20 = (ten_bit_encoded_data_in[5:0] == 6'b110001)  // LSB to right
                          | (ten_bit_encoded_data_in[5:0] == 6'b110010)
                          | (ten_bit_encoded_data_in[5:0] == 6'b110100);

// Control signals must be called out when recognized.
  wire    LSB_is_23_27_29_30 = (   (ten_bit_encoded_data_in[5:4] == 2'b01)
                                 & (LSB_bottom_4_Population[2:0] == 3'h3) )
                             | (   (ten_bit_encoded_data_in[5:4] == 2'b10)
                                 & (LSB_bottom_4_Population[2:0] == 3'h1) );

  wire    LSB_is_K28  = (ten_bit_encoded_data_in[5:0] == 6'b111100)  // LSB to right
                      | (ten_bit_encoded_data_in[5:0] == 6'b000011);

// calculate the bottom 4 bits of decoded data
  wire   [3:0] LSB_XOR_Term = {4{LSB_Invert_Before_Use}}  // invert all signals with alternate values
                            | {1'b0,  LSB_is_0_16_a, LSB_is_0_16_a,  1'b0}  // make 0, 16 into 0
                            | {LSB_is_0_16_b,  1'b0, 1'b0,  LSB_is_0_16_b}  // make 0, 16 into 0
                            | {LSB_is_15_31_a, 1'b0, LSB_is_15_31_a, 1'b0}  // make 15, 31 into 15
                            | {1'b0, LSB_is_15_31_b, 1'b0, LSB_is_15_31_b}  // make 15, 31 into 15
                            | {1'b0, LSB_is_24_a,    1'b0,           1'b0}  // make 24 into 24
                            | {LSB_is_24_b, 1'b0, LSB_is_24_b, LSB_is_24_b};  // make 24 into 24

  assign  decoded_data[3:0] = ten_bit_encoded_data_in[3:0] ^ LSB_XOR_Term[3:0];

// The next bit is harder.  I don't know if this is minimal
  assign  decoded_data[4] = (ten_bit_encoded_data_in[5:0] == 6'b001001)  // LSB to right
                          | (ten_bit_encoded_data_in[5:0] == 6'b001010)
                          | (ten_bit_encoded_data_in[5:0] == 6'b001100)
                          | (ten_bit_encoded_data_in[5:3] == 3'b110)
                          | (   (ten_bit_encoded_data_in[5:4] == 2'b01)
                              & (LSB_bottom_4_Population[2:0] == 3'h2) )
                          | LSB_is_23_27_29_30
                          | LSB_is_K28;

// Calculate the values for the 4 -> 3 decoding

// The bottom 2 bits of the MSB must always be inverted before use in these
//    cases:  (MSB right)  0011, 1101, 0001
// When the LSB indicate that the byte contains a K28, and the bottom 6 bits
//   have a negative disparity, invert these before using: (MSB right)
//   0110, 1010, 0101, 1001
// Only 2 of these are needed to greate singular commas.  I don't understand
//   why they made the other special cases.  Very odd

  wire    MSB_Invert_Before_Use = (ten_bit_encoded_data_in[9:6] == 4'b1100)  // LSB to right
                                | (ten_bit_encoded_data_in[9:6] == 4'b1011)
                                | (ten_bit_encoded_data_in[9:6] == 4'b1000)
                                | (   (ten_bit_encoded_data_in[5:0] == 6'b000011)
                                    & (   (ten_bit_encoded_data_in[9:6] == 4'b0110)
                                        | (ten_bit_encoded_data_in[9:6] == 4'b0101)
                                        | (ten_bit_encoded_data_in[9:6] == 4'b1010)
                                        | (ten_bit_encoded_data_in[9:6] == 4'b1001)
                                      )
                                  );

// Values must be substituted in these cases:
  wire    MSB_0_value_a = (ten_bit_encoded_data_in[9:6] == 4'b0010);  // LSB to right
  wire    MSB_0_value_b = (ten_bit_encoded_data_in[9:6] == 4'b1101);

  wire    alternate_MSB_a = (ten_bit_encoded_data_in[9:6] == 4'b1110);  // LSB to right
  wire    alternate_MSB_b = (ten_bit_encoded_data_in[9:6] == 4'b0001);

  wire    primary_MSB_a = (ten_bit_encoded_data_in[9:6] == 4'b0111);  // LSB to right
  wire    primary_MSB_b = (ten_bit_encoded_data_in[9:6] == 4'b1000);

  wire   [2:0] MSB_XOR_Term = {3{MSB_Invert_Before_Use}}
                            | {1'b0, MSB_0_value_a, 1'b0}
                            | {MSB_0_value_b, 1'b0, MSB_0_value_b}
                            | {1'b0, 1'b0, alternate_MSB_a}
                            | {alternate_MSB_b, alternate_MSB_b, 1'b0};

  assign  decoded_data[7:5] = ten_bit_encoded_data_in[8:6] ^ MSB_XOR_Term[2:0];

  wire    decoded_control = (   LSB_is_23_27_29_30
                              & (alternate_MSB_a | alternate_MSB_b))
                          | LSB_is_K28;

// Keep track of the running disparity.  If 1'b1, the disparity is positive.

  wire   [1:0] MSB_01_Population = ten_bit_encoded_data_in[6]  // half adder
                                 + ten_bit_encoded_data_in[7];
  wire   [1:0] MSB_23_Population = ten_bit_encoded_data_in[8]  // half adder
                                 + ten_bit_encoded_data_in[9];
  wire   [2:0] MSB_Population = {1'b0, MSB_01_Population[1:0]}  // 1, 2, 3
                              + {1'b0, MSB_23_Population[1:0]};

  wire   [3:0] Code_Population = {1'b0, LSB_Population[2:0]}  // 4, 5, 6
                               + {1'b0, MSB_Population[2:0]};

  reg     Running_Disparity;

  always @(posedge clk)
  begin
    if (reset == 1'b1)
    begin
      Running_Disparity <= 1'b0;  // start negative
    end
    else
    begin
      Running_Disparity <= (Code_Population[3:0] == 4'h6)
                         ? 1'b1
                         : (   (Code_Population[3:0] == 4'h4)
                             ? 1'b0
                             : Running_Disparity);
    end
  end

// Detect invalid code values.

  wire    too_many_bits_in_first_nibble =
                (LSB_bottom_4_Population[2:0] > 3'h3);
  wire    too_few_bits_in_first_nibble =
                (LSB_bottom_4_Population[2:0] < 3'h1);

  wire    too_many_bits_in_LSB = (LSB_Population[2:0] > 3'h4);
  wire    too_few_bits_in_LSB = (LSB_Population[2:0] < 3'h2);

  wire    too_many_bits_in_MSB = (MSB_Population[2:0] > 3'h3);
  wire    too_few_bits_in_MSB = (LSB_Population[2:0] < 3'h1);

  wire    too_many_bits_in_entire_code = (Code_Population[3:0] > 4'h6);
  wire    too_few_bits_in_entire_code = (Code_Population[3:0] < 4'h4);

  wire    LSB_inconsistent_with_running_disparity =
                  (   (Running_Disparity == 1'b1)
                    & (   (LSB_Population[2:0] == 3'h4)
                        | (ten_bit_encoded_data_in[5:0] == 6'b000111)  // X.7 negative disparity
                      ) )
                | (   (Running_Disparity == 1'b0)
                    & (   (LSB_Population[2:0] == 3'h2)
                        | (ten_bit_encoded_data_in[5:0] == 6'b111000)  // X.7 positive disparity
                      ) );

  wire    LSB_code_7_positive_but_MSB_inconsistent =
                  (ten_bit_encoded_data_in[5:0] == 6'b111000)  // X.7 positive disparity
                & (   (MSB_Population[2:0] == 3'h3)  // too many bits in MSB
                    | (ten_bit_encoded_data_in[9:6] == 4'b0011)  // Y.3 negative disparity
                  );

  wire    LSB_code_7_negative_but_MSB_inconsistent =
                  (ten_bit_encoded_data_in[5:0] == 6'b000111)  // X.7 negative disparity
                & (   (MSB_Population[2:0] == 3'h1)  // too few bits in MSB
                    | (ten_bit_encoded_data_in[9:6] == 4'b1100)  // Y.3 positive disparity
                  );

  wire    MSB_code_3_positive_but_LSB_inconsistent =
                  (ten_bit_encoded_data_in[9:6] == 4'b1100)  // X.7 positive disparity
                & (LSB_Population[2:0] == 3'h2);  // too few bits in LSB

  wire    MSB_code_3_negative_but_LSB_inconsistent =
                  (ten_bit_encoded_data_in[9:6] == 4'b0011)  // X.7 negative disparity
                & (LSB_Population[2:0] == 3'h4);  // too many bits in LSB

  wire    alternate_encoding_not_used_when_required =
                  ((Running_Disparity == 1'b1) & (LSB_is_11_13_14) & primary_MSB_b)
                | ((Running_Disparity == 1'b0) & (LSB_is_17_18_20) & primary_MSB_a)
                | (LSB_is_K28 & (primary_MSB_a | primary_MSB_b));

  wire    primary_encoding_not_used_when_required =
                  ((Running_Disparity == 1'b0) & (LSB_is_11_13_14) & alternate_MSB_b)
                | ((Running_Disparity == 1'b1) & (LSB_is_17_18_20) & alternate_MSB_a);

  wire    detected_invalid_8b_10b_sequence = too_many_bits_in_first_nibble
                                           | too_few_bits_in_first_nibble
                                           | too_many_bits_in_LSB
                                           | too_few_bits_in_LSB
                                           | too_many_bits_in_MSB
                                           | too_few_bits_in_MSB
                                           | too_many_bits_in_entire_code
                                           | too_few_bits_in_entire_code
                                           | LSB_inconsistent_with_running_disparity
                                           | LSB_code_7_positive_but_MSB_inconsistent
                                           | LSB_code_7_negative_but_MSB_inconsistent
                                           | MSB_code_3_positive_but_LSB_inconsistent
                                           | MSB_code_3_negative_but_LSB_inconsistent
                                           | alternate_encoding_not_used_when_required
                                           | primary_encoding_not_used_when_required;

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
      eight_bit_data_or_control_out[7:0] <= decoded_data[7:0];
      output_is_control <= decoded_control;
      invalid_encoded_data <= detected_invalid_8b_10b_sequence
                            & (ten_bit_encoded_data_in[9:0] != 10'b0000_000000)  // NOTE TEMPORARY
                            ;
    end
  end
endmodule

// `define TEST_8B_10B
`ifdef TEST_8B_10B
// This simulates in between 6 and 7 minutes on a 400 MHz Ultra using verilog XL.
// This does not complete before filling up the disk on a 300 MHz K6 using Verilogger PRO.
module test_8b_10b;
  reg    [8:0] test_data;
  reg    [8:0] test_data_second;
  reg    [8:0] limit;
  reg    [7:0] control_byte;
  reg    [7:0] control_byte_second;
  reg     test_control;

  reg    [7:0] eight_bit_data_or_control_in;
  reg     input_is_control;
  reg     mess_up_link_disparity;
  wire   [9:0] ten_bit_encoded_data_out;
  wire    invalid_control;

  wire   [7:0] eight_bit_data_or_control_out;
  wire    output_is_control;
  wire    invalid_encoded_data;

  reg     clk, reset;

  reg     found_singular_comma;

task set_to_negative_disparity;
  begin
    clk = 1'b0;  reset = 1'b1; #1;
    clk = 1'b1;  reset = 1'b1; #1;  // do reset, setting sender to negative disparity
    clk = 1'b0;  reset = 1'b1; #1;
    clk = 1'b0;  reset = 1'b0; #1;
  end
endtask

task set_to_positive_disparity;
  begin
    clk = 1'b0;  reset = 1'b1; #1;
    clk = 1'b1;  reset = 1'b1; #1;  // do reset, setting sender to negative disparity
    clk = 1'b0;  reset = 1'b1; #1;
    clk = 1'b0;  reset = 1'b0; #1;

    eight_bit_data_or_control_in[7:0] = 8'b111_00011; #1;
    clk = 1'b1; #1;  // switch to a positive running disparity
    clk = 1'b0; #1;
  end
endtask

task check;
  input disparity;
  input  [7:0] test_data;
  input   do_control;
  reg    [9:0] latched_code;
  begin
    if (disparity == 1'b1)
      set_to_positive_disparity;
    else
      set_to_negative_disparity;

    input_is_control = do_control;
    eight_bit_data_or_control_in[7:0] = test_data[7:0]; #1;  // inputs settle
    clk = 1'b1; #1;  // encoded data available
    clk = 1'b0; #1;

    latched_code[9:0] = ten_bit_encoded_data_out[9:0];

    input_is_control = 1'b0;
    eight_bit_data_or_control_in[7:0] = 8'b010_00011; #1;
    clk = 1'b1; #1;  // decoded data available
    clk = 1'b0; #1;

    if (   (eight_bit_data_or_control_out[7:0] !== test_data[7:0])
         | (output_is_control !== do_control)
         | (invalid_encoded_data !== 1'b0)
       )
    begin
      $display ("!!! test data, result %d %d %b_%b %x %d %b %b",
                 test_data[7:5], test_data[4:0],
                 latched_code[9:6], latched_code[5:0],
                 eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                 output_is_control, invalid_encoded_data);
    end
  end
endtask

function look_for_singular_comma;
  input  [6:0] data;
  begin
    if (   (data[0] == data[1])
         & (data[0] == ~data[2])
         & (data[0] == ~data[3])
         & (data[0] == ~data[4])
         & (data[0] == ~data[5])
         & (data[0] == ~data[6])
       )
    begin
      look_for_singular_comma = 1'b1;
    end
    else
    begin
      look_for_singular_comma = 1'b0;
    end
  end
endfunction

task check_pair;  // Data then Data or Control then Data
  input disparity;
  input  [7:0] test_data;
  input  [7:0] test_data_second;
  input   do_control;
  input   want_singular_comma;
  reg    [9:0] latched_code;
  reg    [19:0] two_bytes_of_codes_back_to_back;

  begin
    if (disparity == 1'b1)
      set_to_positive_disparity;
    else
      set_to_negative_disparity;

    input_is_control = do_control;
    eight_bit_data_or_control_in[7:0] = test_data[7:0]; #1;  // inputs settle
    clk = 1'b1; #1;  // encoded data available
    clk = 1'b0; #1;

    latched_code[9:0] = ten_bit_encoded_data_out[9:0];
    two_bytes_of_codes_back_to_back[9:0] = ten_bit_encoded_data_out[9:0];

    input_is_control = 1'b0;
    eight_bit_data_or_control_in[7:0] = test_data_second[7:0]; #1;  // inputs settle
    clk = 1'b1; #1;  // decoded data available
    clk = 1'b0; #1;

    if (   (eight_bit_data_or_control_out[7:0] !== test_data[7:0])
         | (output_is_control !== do_control)
         | (invalid_encoded_data !== 1'b0)
       )
    begin
      $display ("!!! test data, result %d %d %b_%b %x %d %b %b",
                 test_data[7:5], test_data[4:0],
                 latched_code[9:6], latched_code[5:0],
                 eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                 output_is_control, invalid_encoded_data);
    end

    latched_code[9:0] = ten_bit_encoded_data_out[9:0];
    two_bytes_of_codes_back_to_back[19:10] = ten_bit_encoded_data_out[9:0];

    input_is_control = 1'b0;
    eight_bit_data_or_control_in[7:0] = 8'b010_00011; #1;
    clk = 1'b1; #1;  // decoded data available
    clk = 1'b0; #1;

    if (   (eight_bit_data_or_control_out[7:0] !== test_data_second[7:0])
         | (output_is_control !== 1'b0)
         | (invalid_encoded_data !== 1'b0)
       )
    begin
      $display ("!!! test data second, result %d %d %b_%b %x %d %b %b",
                 test_data_second[7:5], test_data_second[4:0],
                 latched_code[9:6], latched_code[5:0],
                 eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                 output_is_control, invalid_encoded_data);
    end

    if (~want_singular_comma)
    begin
      if (   look_for_singular_comma (two_bytes_of_codes_back_to_back[6:0])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[7:1])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[8:2])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[9:3])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[10:4])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[11:5])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[12:6])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[13:7])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[14:8])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[15:9])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[16:10])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[17:11])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[18:12])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[19:13]) )
      begin
        $display ("!!! unexpected singular comma, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
    end
    else  // want a singular comma
    begin
      if (!look_for_singular_comma (two_bytes_of_codes_back_to_back[6:0]))
      begin
        $display ("!!! missing singular comma, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
      if (   look_for_singular_comma (two_bytes_of_codes_back_to_back[7:1])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[8:2])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[9:3])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[10:4])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[11:5])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[12:6])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[13:7])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[14:8])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[15:9])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[16:10])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[17:11])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[18:12])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[19:13]) )
      begin
        $display ("!!! unexpected singular comma, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
    end
  end
endtask

task check_pair_2;  // Data followed by Control or Control followed by Control
  input disparity;
  input  [7:0] test_data;
  input  [7:0] test_data_second;
  input   first_control;
  input   want_first_singular_comma;
  input   second_control;
  input   want_second_singular_comma;
  reg    [9:0] latched_code;
  reg    [19:0] two_bytes_of_codes_back_to_back;

  begin
    if (disparity == 1'b1)
      set_to_positive_disparity;
    else
      set_to_negative_disparity;

    input_is_control = first_control;
    eight_bit_data_or_control_in[7:0] = test_data[7:0]; #1;  // inputs settle
    clk = 1'b1; #1;  // encoded data available
    clk = 1'b0; #1;

    latched_code[9:0] = ten_bit_encoded_data_out[9:0];
    two_bytes_of_codes_back_to_back[9:0] = ten_bit_encoded_data_out[9:0];

    input_is_control = second_control;
    eight_bit_data_or_control_in[7:0] = test_data_second[7:0]; #1;  // inputs settle
    clk = 1'b1; #1;  // decoded data available
    clk = 1'b0; #1;

    if (   (eight_bit_data_or_control_out[7:0] !== test_data[7:0])
         | (output_is_control !== first_control)
         | (invalid_encoded_data !== 1'b0)
       )
    begin
      $display ("!!! test data, result %d %d %b_%b %x %d %b %b",
                 test_data[7:5], test_data[4:0],
                 latched_code[9:6], latched_code[5:0],
                 eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                 output_is_control, invalid_encoded_data);
    end

    latched_code[9:0] = ten_bit_encoded_data_out[9:0];
    two_bytes_of_codes_back_to_back[19:10] = ten_bit_encoded_data_out[9:0];

    input_is_control = 1'b0;
    eight_bit_data_or_control_in[7:0] = 8'b010_00011; #1;
    clk = 1'b1; #1;  // decoded data available
    clk = 1'b0; #1;

    if (   (eight_bit_data_or_control_out[7:0] !== test_data_second[7:0])
         | (output_is_control !== second_control)
         | (invalid_encoded_data !== 1'b0)
       )
    begin
      $display ("!!! test data second, result %d %d %b_%b %x %d %b %b",
                 test_data_second[7:5], test_data_second[4:0],
                 latched_code[9:6], latched_code[5:0],
                 eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                 output_is_control, invalid_encoded_data);
    end

    if (~want_first_singular_comma)
    begin
      if (   look_for_singular_comma (two_bytes_of_codes_back_to_back[6:0])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[7:1])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[8:2])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[9:3])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[10:4])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[11:5])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[12:6])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[13:7])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[14:8])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[15:9]) )
      begin
        $display ("!!! unexpected singular comma, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
    end
    else  // want a singular comma in the first byte
    begin
      if (!look_for_singular_comma (two_bytes_of_codes_back_to_back[6:0]))
      begin
        $display ("!!! missing singular comma, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
      if (   look_for_singular_comma (two_bytes_of_codes_back_to_back[7:1])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[8:2])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[9:3])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[10:4])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[11:5])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[12:6])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[13:7])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[14:8])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[15:9]) )
      begin
        $display ("!!! unexpected singular comma, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
    end
    if (~want_second_singular_comma)
    begin
      if (   look_for_singular_comma (two_bytes_of_codes_back_to_back[16:10])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[17:11])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[18:12])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[19:13]) )
      begin
        $display ("!!! unexpected singular comma, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
    end
    else  // want a singular comma in the second byte
    begin
      if (!look_for_singular_comma (two_bytes_of_codes_back_to_back[16:10]))
      begin
        $display ("!!! missing singular comma 2, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
      if (   look_for_singular_comma (two_bytes_of_codes_back_to_back[17:11])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[18:12])
           | look_for_singular_comma (two_bytes_of_codes_back_to_back[19:13]) )
      begin
        $display ("!!! unexpected singular comma 2, result %d %d %b_%b %b_%b %b %b %b %b",
                   test_data[7:0], test_data_second[7:0],
                   two_bytes_of_codes_back_to_back[9:6], two_bytes_of_codes_back_to_back[5:0],
                   two_bytes_of_codes_back_to_back[19:16], two_bytes_of_codes_back_to_back[15:10],
                   eight_bit_data_or_control_out[7:5], eight_bit_data_or_control_out[4:0],
                   output_is_control, invalid_encoded_data);
      end
    end
  end
endtask

function [7:0] pick_control_byte;
  input  [3:0] index;
  begin
    case (index[3:0])
      0:       pick_control_byte[7:0] = `K_23_7;
      1:       pick_control_byte[7:0] = `K_27_7;
      2:       pick_control_byte[7:0] = `K_28_0;
      3:       pick_control_byte[7:0] = `K_28_1;
      4:       pick_control_byte[7:0] = `K_28_2;
      5:       pick_control_byte[7:0] = `K_28_3;
      6:       pick_control_byte[7:0] = `K_28_4;
      7:       pick_control_byte[7:0] = `K_28_5;
      8:       pick_control_byte[7:0] = `K_28_6;
      9:       pick_control_byte[7:0] = `K_28_7;
      10:      pick_control_byte[7:0] = `K_29_7;
      default: pick_control_byte[7:0] = `K_30_7;
    endcase
  end
endfunction

  initial
  begin
    mess_up_link_disparity = 1'b0;

    $display ("test 32 LSB data values starting with negative disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h020;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (0, test_data[7:0], 1'b0);
    end

    $display ("test 8 MSB data values starting with negative disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h008;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (0, (test_data[2:0] << 5) | 5'h03, 1'b0);
    end

    $display ("test 8 MSB data values starting with negative disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h008;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (0, (test_data[2:0] << 5) | 5'h0B, 1'b0);  // 11
    end

    $display ("test 8 MSB data values starting with negative disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h008;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (0, (test_data[2:0] << 5) | 5'h11, 1'b0);  // 17
    end

    $display ("test control starting with negative disparity");
    check (0, `K_23_7, 1'b1);
    check (0, `K_27_7, 1'b1);
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h008;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (0, `K_28_0 | (test_data[2:0] << 5), 1'b1);
    end
    check (0, `K_29_7, 1'b1);
    check (0, `K_30_7, 1'b1);

//    $display ("invalid control character with negative disparity");
//    check (0, 8'h0, 1'b1);


    $display ("test 32 LSB data values starting with positive disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h020;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (1, test_data[7:0], 1'b0);
    end

    $display ("test 8 MSB data values starting with positive disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h008;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (1, (test_data[2:0] << 5) | 5'h03, 1'b0);
    end

    $display ("test 8 MSB data values starting with positive disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h008;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (1, (test_data[2:0] << 5) | 5'h0B, 1'b0);  // 11
    end

    $display ("test 8 MSB data values starting with positive disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h008;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (1, (test_data[2:0] << 5) | 5'h11, 1'b0);  // 17
    end

    $display ("test control starting with positive disparity");
    check (1, `K_23_7, 1'b1);
    check (1, `K_27_7, 1'b1);
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h008;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      check (1, `K_28_0 | (test_data[2:0] << 5), 1'b1);
    end
    check (1, `K_29_7, 1'b1);
    check (1, `K_30_7, 1'b1);

//    $display ("invalid control character with positive disparity");
//    check (1, 8'h0, 1'b1);

    limit[8:0] = 9'h100;  # 1;

    $display ("trying all byte pairs starting with negative disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h100;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      for (test_data_second[8:0] = 9'h000; test_data_second[8:0] < limit[8:0];
                        test_data_second[8:0] = test_data_second[8:0] + 9'h001)
      begin
        check_pair (0, test_data[7:0], test_data_second[7:0], 1'b0, 1'b0);
      end
    end

    $display ("trying all controls then bytes with negative disparity");
    $display ("This finds 24 unexpected extra singular commas when sending K_28_7");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h100;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      for (test_data_second[3:0] = 4'h0; test_data_second[3:0] < 4'hC;
           test_data_second[3:0] = test_data_second[3:0] + 4'h1)
      begin
        check_pair (0, pick_control_byte(test_data_second[3:0]), test_data[7:0], 1'b1,
                         (test_data_second[3:0] == 4'h3)
                       | (test_data_second[3:0] == 4'h7)
                       | (test_data_second[3:0] == 4'h9) );
      end
    end

    $display ("trying all bytes then controls with negative disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h100;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      for (test_data_second[3:0] = 4'h0; test_data_second[3:0] < 4'hC;
           test_data_second[3:0] = test_data_second[3:0] + 4'h1)
      begin
        check_pair_2 (0, test_data[7:0], pick_control_byte(test_data_second[3:0]),
                       1'b0, 1'b0,
                       1'b1,   (test_data_second[3:0] == 4'h3)
                             | (test_data_second[3:0] == 4'h7)
                             | (test_data_second[3:0] == 4'h9) );
      end
    end

    $display ("trying all controls then controls with negative disparity");
    $display ("This finds 8 unexpected extra singular commas when sending K_28_7");
    for (test_data[3:0] = 9'h000; test_data[3:0] < 4'hC;
                      test_data[3:0] = test_data[3:0] + 4'h1)
    begin
      for (test_data_second[3:0] = 4'h0; test_data_second[3:0] < 4'hC;
           test_data_second[3:0] = test_data_second[3:0] + 4'h1)
      begin
        check_pair_2 (0, pick_control_byte(test_data[3:0]),
                         pick_control_byte(test_data_second[3:0]),
                       1'b1,   (test_data[3:0] == 4'h3)
                             | (test_data[3:0] == 4'h7)
                             | (test_data[3:0] == 4'h9),
                       1'b1,   (test_data_second[3:0] == 4'h3)
                             | (test_data_second[3:0] == 4'h7)
                             | (test_data_second[3:0] == 4'h9) );
      end
    end

    $display ("trying all byte pairs starting with positive disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h100;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      for (test_data_second[8:0] = 9'h000; test_data_second[8:0] < limit[8:0];
                        test_data_second[8:0] = test_data_second[8:0] + 9'h001)
      begin
        check_pair (1, test_data[7:0], test_data_second[7:0], 1'b0, 1'b0);
      end
    end

    $display ("trying all controls then bytes with positive disparity");
    $display ("This finds 24 unexpected extra singular commas when sending K_28_7");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h100;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      for (test_data_second[3:0] = 4'h0; test_data_second[3:0] < 4'hC;
           test_data_second[3:0] = test_data_second[3:0] + 4'h1)
      begin
        check_pair (1, pick_control_byte(test_data_second[3:0]), test_data[7:0], 1'b1,
                         (test_data_second[3:0] == 4'h3)
                       | (test_data_second[3:0] == 4'h7)
                       | (test_data_second[3:0] == 4'h9) );
      end
    end

    $display ("trying all bytes then controls with positive disparity");
    for (test_data[8:0] = 9'h000; test_data[8:0] < 9'h100;
                      test_data[8:0] = test_data[8:0] + 9'h001)
    begin
      for (test_data_second[3:0] = 4'h0; test_data_second[3:0] < 4'hC;
           test_data_second[3:0] = test_data_second[3:0] + 4'h1)
      begin
        check_pair_2 (1, test_data[7:0], pick_control_byte(test_data_second[3:0]),
                       1'b0, 1'b0,
                       1'b1,   (test_data_second[3:0] == 4'h3)
                             | (test_data_second[3:0] == 4'h7)
                             | (test_data_second[3:0] == 4'h9) );
      end
    end

    $display ("trying all controls then controls with positive disparity");
    $display ("This finds 8 unexpected extra singular commas when sending K_28_7");
    for (test_data[3:0] = 9'h000; test_data[3:0] < 4'hC;
                      test_data[3:0] = test_data[3:0] + 4'h1)
    begin
      for (test_data_second[3:0] = 4'h0; test_data_second[3:0] < 4'hC;
           test_data_second[3:0] = test_data_second[3:0] + 4'h1)
      begin
        check_pair_2 (1, pick_control_byte(test_data[3:0]),
                         pick_control_byte(test_data_second[3:0]),
                       1'b1,   (test_data[3:0] == 4'h3)
                             | (test_data[3:0] == 4'h7)
                             | (test_data[3:0] == 4'h9),
                       1'b1,   (test_data_second[3:0] == 4'h3)
                             | (test_data_second[3:0] == 4'h7)
                             | (test_data_second[3:0] == 4'h9) );
      end
    end
  end

encode_8b_10b encode_8b_10b (
  .eight_bit_data_or_control_in (eight_bit_data_or_control_in[7:0]),
  .input_is_control           (input_is_control),
  .mess_up_link_disparity     (mess_up_link_disparity),
  .ten_bit_encoded_data_out   (ten_bit_encoded_data_out[9:0]),
  .invalid_control            (invalid_control),
  .clk                        (clk),
  .reset                      (reset)
);

decode_10b_8b decode_10b_8b (
  .ten_bit_encoded_data_in    (ten_bit_encoded_data_out[9:0]),
  .eight_bit_data_or_control_out (eight_bit_data_or_control_out[7:0]),
  .output_is_control          (output_is_control),
  .invalid_encoded_data       (invalid_encoded_data),
  .clk                        (clk),
  .reset                      (reset)
);
endmodule
`endif  // TEST_8B_10B

// `define DISCOVER_WHICH_CODES_ARE_ILLEGAL
`ifdef DISCOVER_WHICH_CODES_ARE_ILLEGAL
module figure_out_error_patterns;

// NOTE: For the purpose of comparing with the patent, this exploration
//         module uses the notation that the LEFTMOST BIT is the LSB.
//       All other modules use the more normal Rightmost Bit == bit 0 == LSB

  reg    [10:0] i;

  reg    [9:0] full_addr; 
  reg    [4095:0] valid;  // storage
  reg    [4095:0] invalid;  // storage

task do_one;
  input  [3:0] high_addr;
  begin
    full_addr[3:0] = high_addr[3:0];  // note LSB to left
    valid[full_addr[9:0]] = 1'b1;
  end
endtask

task mark_both;
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

task mark_positive;
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

task mark_negative;
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

task mark_all;
  begin
    mark_positive;
    mark_negative;
    mark_both;
  end
endtask

task mark;
  input  [5:0] val;
  input   type;
  integer type;

  begin
    full_addr[9:4] = val[5:0];  // note LSB to left
    if (type == 0)
    begin
      mark_all;
    end
    else if (type == 1)
    begin
      mark_positive;
      mark_both;
    end
    else
    begin
      mark_negative;
      mark_both;
    end
  end
endtask

initial
  begin

// Clear all bits
    for (i[10:0] = 11'h000; i[10:0] < 11'h400; i[10:0] = i[10:0] + 11'h001)
    begin
      valid[i[9:0]] = 1'b0;
      invalid[full_addr[9:0]] = 1'b0;
    end

// Mark patterns which are parts of valid codes
    mark (6'b110001, 0);
    mark (6'b101001, 0);
    mark (6'b011001, 0);
    mark (6'b100101, 0);
    mark (6'b010101, 0);
    mark (6'b110100, 0);
    mark (6'b001101, 0);
    mark (6'b101100, 0);
    mark (6'b011100, 0);
    mark (6'b100011, 0);
    mark (6'b010011, 0);
    mark (6'b110010, 0);
    mark (6'b001011, 0);
    mark (6'b101010, 0);
    mark (6'b011010, 0);
    mark (6'b100110, 0);
    mark (6'b010110, 0);
    mark (6'b001110, 0);

    mark (6'b011000, -1);
    mark (6'b100010, -1);
    mark (6'b010010, -1);
    mark (6'b001010, -1);
    mark (6'b111000, -1);
    mark (6'b000110, -1);
    mark (6'b101000, -1);
    mark (6'b100100, -1);
    mark (6'b000101, -1);
    mark (6'b001100, -1);
    mark (6'b001001, -1);
    mark (6'b010001, -1);
    mark (6'b100001, -1);
    mark (6'b010100, -1);

    mark (6'b100111, +1);
    mark (6'b011101, +1);
    mark (6'b101101, +1);
    mark (6'b110101, +1);
    mark (6'b000111, +1);
    mark (6'b111001, +1);
    mark (6'b010111, +1);
    mark (6'b011011, +1);
    mark (6'b111010, +1);
    mark (6'b110011, +1);
    mark (6'b110110, +1);
    mark (6'b101110, +1);
    mark (6'b011110, +1);
    mark (6'b101011, +1);

// Mark patterns which are control codes.
    valid[ 10'b111010_1000] = 1'b1;
    valid[ 10'b110110_1000] = 1'b1;
    valid[ 10'b101110_1000] = 1'b1;
    valid[ 10'b011110_1000] = 1'b1;

    valid[ 10'b001111_0100] = 1'b1;
    valid[ 10'b001111_1001] = 1'b1;
    valid[ 10'b001111_0101] = 1'b1;
    valid[ 10'b001111_0011] = 1'b1;
    valid[ 10'b001111_0010] = 1'b1;
    valid[ 10'b001111_1010] = 1'b1;
    valid[ 10'b001111_0110] = 1'b1;
    valid[ 10'b001111_1000] = 1'b1;

    valid[~10'b111010_1000] = 1'b1;
    valid[~10'b110110_1000] = 1'b1;
    valid[~10'b101110_1000] = 1'b1;
    valid[~10'b011110_1000] = 1'b1;

    valid[~10'b001111_0100] = 1'b1;
    valid[~10'b001111_1001] = 1'b1;
    valid[~10'b001111_0101] = 1'b1;
    valid[~10'b001111_0011] = 1'b1;
    valid[~10'b001111_0010] = 1'b1;
    valid[~10'b001111_1010] = 1'b1;
    valid[~10'b001111_0110] = 1'b1;
    valid[~10'b001111_1000] = 1'b1;

    for (i[10:0] = 11'h000; i[10:0] < 11'h400; i[10:0] = i[10:0] + 11'h001)
    begin
// Get rid of patterns in the 6 LSB with less than 2 or greater than 4 bits set.
      if ((i[9] + i[8] + i[7] + i[6] + i[5] + i[4]) < 2)
      begin
        invalid[i[9:0]] = 1'b1;
      end
      if ((i[9] + i[8] + i[7] + i[6] + i[5] + i[4]) > 4)
      begin
        invalid[i[9:0]] = 1'b1;
      end
// Get rid of patterns in the 4 MSB with less than 1 or greater than 3 bits set.
      if ((i[3:0] == 4'h0) | (i[3:0] == 4'hF))
      begin
        invalid[i[9:0]] = 1'b1;
      end
// Get rid of total patterns with less than 4 or greater than 6 bits set.
      if ((i[0] + i[1] + i[2] + i[3] + i[4] + i[5] + i[6] + i[7] + i[8] + i[9]) < 4)
      begin
        invalid[i[9:0]] = 1'b1;
      end
      if ((i[0] + i[1] + i[2] + i[3] + i[4] + i[5] + i[6] + i[7] + i[8] + i[9]) > 6)
      begin
        invalid[i[9:0]] = 1'b1;
      end
// Get rid of patterns with the 4 LSB all 0 or all 1
      if ((i[9:6] == 4'b0000) | (i[9:6] == 4'b1111))
      begin
        invalid[i[9:0]] = 1'b1;
      end
// Get rid of patterns which use D.7.y with the wrong disparity.  8
      if ((i[9:4] == 6'b111000) & (i[3] + i[2] + i[1] + i[0] == 1))  // minus then minus
      begin
        invalid[i[9:0]] = 1'b1;
      end
      if ((i[9:4] == 6'b000111) & (i[3] + i[2] + i[1] + i[0] == 3))  // plus then plus
      begin
        invalid[i[9:0]] = 1'b1;
      end
// Get rid of patterns which use D.x.3 with the wrong disparity.  28
      if (   (i[3:0] == 4'b0011)
           & ((i[9] + i[8] + i[7] + i[6] + i[5] + i[4]) == 2))
      begin
        invalid[i[9:0]] = 1'b1;
      end
      if (   (i[3:0] == 4'b1100)
           & ((i[9] + i[8] + i[7] + i[6] + i[5] + i[4]) == 4))
      begin
        invalid[i[9:0]] = 1'b1;
      end
    end

// Get rid of case when D.x.3 and D.7.y are used together as D.7.3
    valid[10'b111000_0011] = 1'b1;
    valid[10'b000111_1100] = 1'b1;

    for (i[10:0] = 11'h000; i[10:0] < 11'h400; i[10:0] = i[10:0] + 11'h001)
    begin
// Get rid of non-control codes which use alternate encoding inappropriately.  32
// These are all the data items except 23, 27, 29, and 30 which do not end in
//   00 or 11 as the MSB.  This excludes control codes, which use alternate encoding.
      if (   (i[9:4] != 6'b111010) & (i[9:4] != 6'b000101)  // 23
           & (i[9:4] != 6'b110110) & (i[9:4] != 6'b001001)  // 27
           & (i[9:4] != 6'b101110) & (i[9:4] != 6'b010001)  // 29
           & (i[9:4] != 6'b011110) & (i[9:4] != 6'b100001)  // 30
           & (i[9:4] != 6'b001111) & (i[9:4] != 6'b110000)  // K28
           & (i[9:4] != 6'b110100)  // 11
           & (i[9:4] != 6'b101100)  // 13
           & (i[9:4] != 6'b011100)  // 14
           & (i[9:4] != 6'b100011)  // 17
           & (i[9:4] != 6'b010011)  // 18
           & (i[9:4] != 6'b001011)  // 20
         )
      begin
        if ((i[3:0] == 4'b0111) | (i[3:0] == 4'b1000))
        begin
          invalid[i[9:0]] = 1'b1;  // not a candidate for alternate D7 at all
        end
      end

      if (   (i[9:4] == 6'b110000)  // K28
           | (i[9:4] == 6'b001111)  // K28
           | (i[9:4] == 6'b110100)  // 11
           | (i[9:4] == 6'b101100)  // 13
           | (i[9:4] == 6'b011100)  // 14
         )
      begin
        if (i[3:0] == 4'b0001)  // cant use normal +
        begin
          invalid[i[9:0]] = 1'b1;
        end
      end

      if (   (i[9:4] == 6'b100011)  // 17
           | (i[9:4] == 6'b010011)  // 18
           | (i[9:4] == 6'b001011)  // 20
         )
      begin
        if (i[3:0] == 4'b1000)  // cant use alternate +
        begin
          invalid[i[9:0]] = 1'b1;
        end
      end

      if (   (i[9:4] == 6'b110000)  // K28
           | (i[9:4] == 6'b001111)  // K28
           | (i[9:4] == 6'b100011)  // 17
           | (i[9:4] == 6'b010011)  // 18
           | (i[9:4] == 6'b001011)  // 20
         )
      begin
        if (i[3:0] == 4'b1110)  // cant use normal -
        begin
          invalid[i[9:0]] = 1'b1;
        end
      end

      if (   (i[9:4] == 6'b110100)  // 11
           | (i[9:4] == 6'b101100)  // 13
           | (i[9:4] == 6'b011100)  // 14
         )
      begin
        if (i[3:0] == 4'b0111)  // cant use alternate -
        begin
          invalid[i[9:0]] = 1'b1;
        end
      end
    end

    $display ("LSB is to the left");
    for (i[10:0] = 11'h000; i[10:0] < 11'h400; i[10:0] = i[10:0] + 11'h001)
    begin
      if ((valid[i[9:0]] !== 1'b1) & (invalid[i[9:0]] !== 1'b1))
      begin
        $display ("not set %b", i[9:0]);
      end
      if ((valid[i[9:0]] === 1'b1) & (invalid[i[9:0]] === 1'b1))
      begin
        $display ("both set %b", i[9:0]);
      end
    end

  end
endmodule
`endif  // DISCOVER_WHICH_CODES_ARE_ILLEGAL
