//------------------------------------------------------------------------
//   This Verilog file was developed by Altera Corporation.  It may be
// freely copied and/or distributed at no cost.  Any persons using this
// file for any purpose do so at their own risk, and are responsible for
// the results of such use.  Altera Corporation does not guarantee that
// this file is complete, correct, or fit for any particular purpose.
// NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
// accompany any copy of this file.
//
//------------------------------------------------------------------------
// Imported to Opencores directory.   Date Sept 10, 2001
// Split related modules into separate files, as the manual splits them.
// Added example instantiations to the beginning of each file.
//
/* EXAMPLE INSTANTIATIONS:

lpm_inpad
#( 1                          // lpm_width (width of input)
 ) lpm_inpad_example (
  .pad                        (data_in[lpm_width-1:0]),
  .result                     (data_out[lpm_width-1:0])
);

lpm_outpad
#( 1                          // lpm_width (width of input)
 ) lpm_outpad_example (
  .pad                        (data_out[lpm_width-1:0]),
  .data                       (data_in[lpm_width-1:0])
);

lpm_bipad
#( 1                          // lpm_width (width of input)
 ) lpm_bipad_example (
  .pad                        (data_bi[lpm_width-1:0]),
  .result                     (data_out[lpm_width-1:0]),
  .data                       (data_in[lpm_width-1:0]),
  .enable                     (oe_data_to_pad)
);
*/

//------------------------------------------------------------------------
// LPM Synthesizable Models
//------------------------------------------------------------------------
// Version 1.5 (lpm 220)      Date 12/17/99
//
// Modified LPM_ADD_SUB and LPM_MULT to accomodate LPM_WIDTH = 1.
//   Default values for LPM_WIDTH* are changed back to 1.
// Added LPM_HINT to LPM_DIVIDE.
// Rewritten LPM_FIFO_DC to output correctly.
// Modified LPM_FIFO to output 0s before first read, output correct
//   values after aclr and sclr, and output LPM_NUMWORDS mod
//   exp(2, LPM_WIDTHU) when FIFO is full.
//
//------------------------------------------------------------------------
// Version 1.4.1 (lpm 220)    Date 10/29/99
//
// Default values for LPM_WIDTH* of LPM_ADD_SUB and LPM_MULT are changed
//   from 1 to 2.
//
//------------------------------------------------------------------------
// Version 1.4 (lpm 220)      Date 10/18/99
//
// Default values for each optional inputs for ALL modules are added.
// Some LPM_PVALUE implementations were missing, and now implemented.
//
//------------------------------------------------------------------------
// Version 1.3 (lpm 220)      Date 06/23/99
//
// Corrected LPM_FIFO and LPM_FIFO_DC cout and empty/full flags.
// Implemented LPM_COUNTER cin/cout, and LPM_MODULUS is now working.
//
//------------------------------------------------------------------------
// Version 1.2 (lpm 220)      Date 06/16/99
//
// Added LPM_RAM_DP, LPM_RAM_DQ, LPM_IO, LPM_ROM, LPM_FIFO, LPM_FIFO_DC.
// Parameters and ports are added/discarded according to the spec.
//
//------------------------------------------------------------------------
// Version 1.1 (lpm 220)      Date 02/05/99
//
// Added LPM_DIVIDE module.
//
//------------------------------------------------------------------------
// Version 1.0                Date 07/09/97
//
//------------------------------------------------------------------------
// Excluded Functions:
//
//  LPM_FSM and LPM_TTABLE.
//
//------------------------------------------------------------------------
// Assumptions:
//
// 1. LPM_SVALUE, LPM_AVALUE, LPM_MODULUS, and LPM_NUMWORDS,
//    LPM_STRENGTH, LPM_DIRECTION, and LPM_PVALUE  default value is
//    string UNUSED.
//
//------------------------------------------------------------------------
// Verilog Language Issues:
//
// Two dimensional ports are not supported. Modules with two dimensional
// ports are implemented as one dimensional signal of (LPM_SIZE * LPM_WIDTH)
// bits wide.
//
//------------------------------------------------------------------------
// Synthesis Issues:
//
// 1. LPM_COUNTER
//
// Currently synthesis tools do not allow mixing of level and edge
// sensetive signals. To overcome that problem the "data" signal is
// removed from the clock always block of lpm_counter, however the
// synthesis result is accurate. For correct simulation add the "data"
// pin to the sensetivity list as follows:
//
//  always @(posedge clock or posedge aclr or posedge aset or
//           posedge aload or data)
//------------------------------------------------------------------------

module lpm_inpad ( result, pad );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_type = "lpm_inpad";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] pad;
	output [lpm_width-1:0] result;

	reg    [lpm_width-1:0] result;

	always @(pad)
	begin
		result = pad;
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_inpad") || (lpm_type !== "lpm_inpad"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_inpad

//------------------------------------------------------------------------

module lpm_outpad ( data, pad );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_type = "lpm_outpad";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input [lpm_width-1:0] data;
	output  [lpm_width-1:0] pad;

	reg   [lpm_width-1:0] pad;

	always @(data)
	begin
		pad = data;
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_outpad") || (lpm_type !== "lpm_outpad"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_outpad

//------------------------------------------------------------------------

module lpm_bipad ( result, pad, data, enable );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_type = "lpm_bipad";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	input  enable;
	inout  [lpm_width-1:0] pad;
	output [lpm_width-1:0] result;

	reg    [lpm_width-1:0] tmp_pad;
	reg    [lpm_width-1:0] result;

	always @(data or pad or enable)
	begin
		if (enable == 1)
		begin
			tmp_pad = data;
			result = 'bz;
		end
		else if (enable == 0)
		begin
			result = pad;
			tmp_pad = 'bz;
		end
	end

	assign pad = tmp_pad;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_bipad") || (lpm_type !== "lpm_bipad"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_bipad
