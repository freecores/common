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

lpm_constant
#( 1,                         // lpm_width
   0,                         // lpm_cvalue
   "UNUSED"                   // lpm_strength, optional, {UNUSED, WEAK}
 ) lpm_constant_example (
  .result                     (const_out[lpm_width-1:0])
);

lpm_inv
#( 1                          // lpm_width
 ) lpm_inv_example (
  .result                     (data_out[lpm_width-1:0]),
  .data                       (data_in[lpm_width-1:0])
);

// NOTE: Bits data[lpm_size-1:0] are ANDed together to make result[0]
lpm_and
#( 1,                         // lpm_width (output width)
   1                          // lpm_size (inputs to each gate)
 ) lpm_and_example (
  .result                     (data_out[lpm_width-1:0]),
  .data                       (data_in[(lpm_size*lpm_width)-1:0])
);

// NOTE: Bits data[lpm_size-1:0] are ORed together to make result[0]
lpm_or
#( 1,                         // lpm_width (output width)
   1                          // lpm_size (inputs to each gate)
 ) lpm_or_example (
  .result                     (data_out[lpm_width-1:0]),
  .data                       (data_in[(lpm_size*lpm_width)-1:0])
);

// NOTE: Bits data_[lpm_size-1:0] are XORed together to make result[0]
lpm_xor
#( 1,                         // lpm_width (output width)
   1                          // lpm_size (inputs to each gate)
 ) lpm_xor_example (
  .result                     (data_out[lpm_width-1:0]),
  .data                       (data_in[(lpm_size*lpm_width)-1:0])
);

lpm_bustri
#( 1                          // lpm_width
 ) lpm_bustri_example (
  .tridata                    (data_tristate[lpm_width-1:0]),
  .data                       (data_to_tristate[lpm_width-1:0]),    // CHOICE
  .enabledt                   (enable_data_to_tristate_bus_HIGH),   // OPTIONAL
  .result                     (data_from_tristate[lpm_width-1:0]),  // CHOICE
  .enabletr                   (enable_data_to_result_bus_HIGH),     // OPTIONAL
);

// NOTE: Bits data[lpm_size-1:0] are SELECTED to make result[0]
lpm_mux
#( 1,                         // lpm_width (output width)
   1,                         // lpm_size (inputs to each mux)
   1,                         // lpm_widths (number of bits in output select bus)
   0                          // lpm_pipeline, optional, {0, 1}
 ) lpm_mux_example (
  .result                     (data_out[lpm_width-1:0]),
  .data                       (data_in[(lpm_size*lpm_width)-1:0]),
  .sel                        (data_sel[lpm_widths-1:0]),
  .clock                      (clock_if_pipelined),              // OPTIONAL
  .clken                      (clock_enable_HIGH_if_pipelined),  // OPTIONAL
  .aclr                       (async_clear_if_pipelined)         // OPTIONAL
);

lpm_decode
#( 1,                         // lpm_width (number of bits in input to be decoded)
   1,                         // lpm_decodes (number of actual outputs decoded)
   0                          // lpm_pipeline, optional, {0, 1}
 ) lpm_decode_example (
  .eq                         (decodes_out[lpm_decodes-1:0]),
  .data                       (data_in[lpm_width:0]),
  .enable                     (force_all_outputs_LOW_when_LOW),  // OPTIONAL
  .clock                      (clock_if_pipelined),              // OPTIONAL
  .clken                      (clock_enable_HIGH_if_pipelined),  // OPTIONAL
  .aclr                       (async_clear_if_pipelined)         // OPTIONAL
);

lpm_clshift
#( 1,                         // lpm_width (width of input vector)
   1,                         // lpm_widthdist (width of shift distance port)
   "LOGICAL"                  // lpm_shifttype, optional, {LOGICAL, ROTATE, ARITHMETIC}
 ) lpm_clshift_example (
  .result                     (data_out[lpm_width-1:0]),
  .overflow                   (overflow_means_arith_bit_lost_or_result_became_0),  // OPTIONAL
  .underflow                  (underflow_means_result_became_0),  // OPTIONAL
  .data                       (data_in[lpm_width-1:0]),
  .direction                  (low_means_towards_LSB),  // OPTIONAL
  .distance                   (shift_distance[lpm_widthdist-1:0])
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

module lpm_constant ( result );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_cvalue = 0;
	parameter lpm_strength = "UNUSED";
	parameter lpm_type = "lpm_constant";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	output [lpm_width-1:0] result;

	assign result = lpm_cvalue;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_constant") || (lpm_type !== "lpm_constant"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_constant

//------------------------------------------------------------------------

module lpm_inv ( result, data );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_type = "lpm_inv";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	output [lpm_width-1:0] result;

	reg    [lpm_width-1:0] result;

	always @(data)
	begin
		result = ~data;
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_inv") || (lpm_type !== "lpm_inv"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_inv

//------------------------------------------------------------------------

module lpm_and ( result, data );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_size = 1;
	parameter lpm_type = "lpm_and";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [(lpm_size * lpm_width)-1:0] data;
	output [lpm_width-1:0] result;

	reg    [lpm_width-1:0] result;
	integer i, j, k;

	always @(data)
	begin
		for (i=0; i<lpm_width; i=i+1)
		begin
			result[i] = data[i];
			for (j=1; j<lpm_size; j=j+1)
			begin
				k = j * lpm_width + i;
				result[i] = result[i] & data[k];
			end
		end
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_and") || (lpm_type !== "lpm_and"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_and

//------------------------------------------------------------------------

module lpm_or ( result, data );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_size = 1;
	parameter lpm_type = "lpm_or";
	parameter lpm_hint  = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [(lpm_size * lpm_width)-1:0] data;
	output [lpm_width-1:0] result;

	reg    [lpm_width-1:0] result;
	integer i, j, k;

	always @(data)
	begin
		for (i=0; i<lpm_width; i=i+1)
		begin
			result[i] = data[i];
			for (j=1; j<lpm_size; j=j+1)
			begin
				k = j * lpm_width + i;
				result[i] = result[i] | data[k];
			end
		end
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_or") || (lpm_type !== "lpm_or"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_or

//------------------------------------------------------------------------

module lpm_xor ( result, data );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_size = 1;
	parameter lpm_type = "lpm_xor";
	parameter lpm_hint  = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [(lpm_size * lpm_width)-1:0] data;
	output [lpm_width-1:0] result;

	reg    [lpm_width-1:0] result;
	integer i, j, k;

	always @(data)
	begin
		for (i=0; i<lpm_width; i=i+1)
		begin
			result[i] = data[i];
			for (j=1; j<lpm_size; j=j+1)
			begin
				k = j * lpm_width + i;
				result[i] = result[i] ^ data[k];
			end
		end
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_xor") || (lpm_type !== "lpm_xor"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_xor

//------------------------------------------------------------------------

module lpm_bustri ( result, tridata, data, enabledt, enabletr );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_type = "lpm_bustri";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	input  enabledt;
	input  enabletr;
	output [lpm_width-1:0] result;
	inout  [lpm_width-1:0] tridata;

	reg    [lpm_width-1:0] result;
	reg    [lpm_width-1:0] tmp_tridata;

	tri0  enabledt;
	tri0  enabletr;
	buf (i_enabledt, enabledt);
	buf (i_enabletr, enabletr);

	always @(data or tridata or i_enabletr or i_enabledt)
	begin
		if (i_enabledt == 0 && i_enabletr == 1)
		begin
			result = tridata;
			tmp_tridata = 'bz;
		end
		else if (i_enabledt == 1 && i_enabletr == 0)
		begin
			result = 'bz;
			tmp_tridata = data;
		end
		else if (i_enabledt == 1 && i_enabletr == 1)
		begin
			result = data;
			tmp_tridata = data;
		end
		else
		begin
			result = 'bz;
			tmp_tridata = 'bz;
		end
	end

	assign tridata = tmp_tridata;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_bustri") || (lpm_type !== "lpm_bustri"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_bustri

//------------------------------------------------------------------------

module lpm_mux ( result, clock, clken, data, aclr, sel );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_size = 1;
	parameter lpm_widths = 1;
	parameter lpm_pipeline = 0;
	parameter lpm_type = "lpm_mux";
	parameter lpm_hint  = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input [(lpm_size * lpm_width)-1:0] data;
	input aclr;
	input clock;
	input clken;
	input [lpm_widths-1:0] sel;
	output [lpm_width-1:0] result;

	integer i, j, m, n;
	reg [lpm_width-1:0] tmp_result;
	reg [lpm_width-1:0] tmp_result2 [lpm_pipeline:0];

	tri0 aclr;
	tri0 clock;
	tri1 clken;

	buf (i_aclr, aclr);
	buf (i_clock, clock);
	buf (i_clken, clken);

	always @(data or sel)
	begin
		tmp_result = 0;
		for (m=0; m<lpm_width; m=m+1)
		begin
			n = sel * lpm_width + m;
			tmp_result[m] = data[n];
		end
	end

	always @(posedge i_clock or posedge i_aclr)
	begin
		if (i_aclr)
		begin
			for (i = 0; i <= lpm_pipeline; i = i + 1)
				tmp_result2[i] = 'b0;
		end
		else if (i_clken == 1)
		begin
			tmp_result2[lpm_pipeline] = tmp_result;
			for (j = 0; j < lpm_pipeline; j = j +1)
				tmp_result2[j] = tmp_result2[j+1];
		end
	end

	assign result = (lpm_pipeline > 0) ? tmp_result2[0] : tmp_result;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_mux") || (lpm_type !== "lpm_mux"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_mux

//------------------------------------------------------------------------

module lpm_decode ( eq, data, enable, clock, clken, aclr );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_decodes = 1 << lpm_width;
	parameter lpm_pipeline = 0;
	parameter lpm_type = "lpm_decode";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	input  enable;
	input  clock;
	input  clken;
	input  aclr;
	output [lpm_decodes-1:0] eq;

	reg    [lpm_decodes-1:0] tmp_eq2 [lpm_pipeline:0];
	reg    [lpm_decodes-1:0] tmp_eq;
	integer i, j;

	tri0   clock;
	tri1   clken;
	tri0   aclr;
	tri1   enable;

	buf (i_clock, clock);
	buf (i_clken, clken);
	buf (i_aclr, aclr);
	buf (i_enable, enable);


	always @(data or i_enable)
	begin
		tmp_eq = 0;
		if (i_enable)
		begin
			if ((data < lpm_decodes))
			begin
				tmp_eq[data] = 1'b1;
			end
		else
			tmp_eq = 0;
		end
	end
 
	always @(posedge i_clock or posedge i_aclr)
	begin
		if (i_aclr)
		begin 
			for (i = 0; i <= lpm_pipeline; i = i + 1)
				tmp_eq2[i] = 'b0;
		end
		else if (clken == 1) 
		begin
			tmp_eq2[lpm_pipeline] = tmp_eq;
			for (j = 0; j < lpm_pipeline; j = j +1)
				tmp_eq2[j] = tmp_eq2[j+1];
		end
	end

	assign eq = (lpm_pipeline > 0) ? tmp_eq2[0] : tmp_eq;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_decode") || (lpm_type !== "lpm_decode"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_decode

//------------------------------------------------------------------------

module lpm_clshift ( result, overflow, underflow, data, direction, distance );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_widthdist = 1;
	parameter lpm_shifttype = "LOGICAL";
	parameter lpm_type = "lpm_clshift";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	input  [lpm_widthdist-1:0] distance;
	input  direction;
	output [lpm_width-1:0] result;
	output overflow;
	output underflow;

	reg    [lpm_width-1:0] ONES;
	reg    [lpm_width-1:0] result;
	reg    overflow, underflow;
	integer i;

	tri0  direction;

	buf (i_direction, direction);

//---------------------------------------------------------------//
	function [lpm_width+1:0] LogicShift;
		input [lpm_width-1:0] data;
		input [lpm_widthdist-1:0] dist;
		input direction;
		reg   [lpm_width-1:0] tmp_buf;
		reg   overflow, underflow;
				
		begin
			tmp_buf = data;
			overflow = 1'b0;
			underflow = 1'b0;
			if ((direction) && (dist > 0)) // shift right
			begin
				tmp_buf = data >> dist;
				if ((data != 0) && ((dist >= lpm_width) || (tmp_buf == 0)))
					underflow = 1'b1;
			end
			else if (dist > 0) // shift left
			begin
				tmp_buf = data << dist;
				if ((data != 0) && ((dist >= lpm_width)
					|| ((data >> (lpm_width-dist)) != 0)))
					overflow = 1'b1;
			end
			LogicShift = {overflow,underflow,tmp_buf[lpm_width-1:0]};
		end
	endfunction

//---------------------------------------------------------------//
	function [lpm_width+1:0] ArithShift;
		input [lpm_width-1:0] data;
		input [lpm_widthdist-1:0] dist;
		input direction;
		reg   [lpm_width-1:0] tmp_buf;
		reg   overflow, underflow;
		
		begin
			tmp_buf = data;
			overflow = 1'b0;
			underflow = 1'b0;

			if (direction && (dist > 0))   // shift right
			begin
				if (data[lpm_width-1] == 0) // positive number
				begin
					tmp_buf = data >> dist;
					if ((data != 0) && ((dist >= lpm_width) || (tmp_buf == 0)))
						underflow = 1'b1;
				end
				else // negative number
				begin
					tmp_buf = (data >> dist) | (ONES << (lpm_width - dist));
					if ((data != ONES) && ((dist >= lpm_width-1) || (tmp_buf == ONES)))
						underflow = 1'b1;
				end
			end
			else if (dist > 0) // shift left
			begin
				tmp_buf = data << dist;
				if (data[lpm_width-1] == 0) // positive number
				begin
					if ((data != 0) && ((dist >= lpm_width-1) 
					|| ((data >> (lpm_width-dist-1)) != 0)))
						overflow = 1'b1;
				end
				else // negative number
				begin
					if ((data != ONES) && ((dist >= lpm_width) 
					|| (((data >> (lpm_width-dist-1))|(ONES << (dist+1))) != ONES)))
						overflow = 1'b1;
				end
			end
			ArithShift = {overflow,underflow,tmp_buf[lpm_width-1:0]};
		end
	endfunction

//---------------------------------------------------------------//
	function [lpm_width-1:0] RotateShift;
		input [lpm_width-1:0] data;
		input [lpm_widthdist-1:0] dist;
		input direction;
		reg   [lpm_width-1:0] tmp_buf;
		
		begin
			tmp_buf = data;
			if ((direction) && (dist > 0)) // shift right
			begin
				tmp_buf = (data >> dist) | (data << (lpm_width - dist));
			end
			else if (dist > 0) // shift left
			begin
				tmp_buf = (data << dist) | (data >> (lpm_width - dist));
			end
			RotateShift = tmp_buf[lpm_width-1:0];
		end
	endfunction
//---------------------------------------------------------------//

	initial
	begin
		for (i=0; i < lpm_width; i=i+1)
			ONES[i] = 1'b1;
	end

	always @(data or i_direction or distance)
	begin
		// lpm_shifttype is optional and default to LOGICAL
		if ((lpm_shifttype == "LOGICAL"))
		begin
			{overflow,underflow,result} = LogicShift(data,distance,i_direction);
		end
		else if (lpm_shifttype == "ARITHMETIC")
		begin
			{overflow,underflow,result} = ArithShift(data,distance,i_direction);
		end
		else if (lpm_shifttype == "ROTATE")
		begin
			result = RotateShift(data, distance, i_direction);
			overflow = 1'b0;
			underflow = 1'b0;
		end
		else
		begin
			result = 'bx;
			overflow = 1'b0;
			underflow = 1'b0;
		end
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_clshift") || (lpm_type !== "lpm_clshift"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_clshift
