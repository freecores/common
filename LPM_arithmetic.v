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

lpm_add_sub
#( 1,                         // lpm_width (width of input vector)
   "UNUSED",                  // lpm_direction, optional, {ADD, SUB}
   "UNSIGNED",                // lpm_representation, optional, {UNSIGNED, SIGNED}
   0                          // lpm_pipeline, optional, {0, 1}
 ) lpm_add_sub_example (
  .result                     (data_out[lpm_width-1:0]),
  .cout                       (carry_out_indicates_unsigned_result_too_big),  // OPTIONAL
  .overflow                   (overflow_indicates_MSB_sign_bit_wrong),  // OPTIONAL
  .dataa                      (data_in[lpm_width-1:0]),
  .datab                      (data_pl_mi_in[lpm_width-1:0]),
  .cin                        (add_1_if_HIGH_sub_1_if_LOW),      // OPTIONAL
  .add_sub                    (add_if_HIGH_must_set_HIGH_if_using_lpm_direction),  // OPTIONAL
  .clock                      (clock_if_pipelined),              // OPTIONAL
  .clken                      (clock_enable_HIGH_if_pipelined),  // OPTIONAL
  .aclr                       (async_clear_if_pipelined)         // OPTIONAL
);

lpm_compare
#( 1,                         // lpm_width (width of input vector)
   "UNSIGNED",                // lpm_representation, optional, {UNSIGNED, SIGNED}
   0                          // lpm_pipeline, optional, {0, 1}
 ) lpm_compare_example (
  .agb                        (a_greater_than_b),
  .ageb                       (a_greater_or_equil_to_b),
  .aeb                        (a_equil_to_b),
  .aleb                       (a_less_or_equil_to_b),
  .alb                        (a_less_than_b),
  .aneb                       (a_not_equil_b),
  .dataa                      (data_in_a[lpm_width-1:0]),
  .datab                      (data_in_a[lpm_width-1:0]),
  .clock                      (clock_if_pipelined),              // OPTIONAL
  .clken                      (clock_enable_HIGH_if_pipelined),  // OPTIONAL
  .aclr                       (async_clear_if_pipelined)         // OPTIONAL
);

module lpm_mult (
#( 1,                         // lpm_widtha (width of input vector)
   1,                         // lpm_widthb (width of input vector)
   1,                         // lpm_widths (width of partial sum vector)
   1,                         // lpm_widthp (width of product vector)
   "UNSIGNED",                // lpm_representation, optional, {UNSIGNED, SIGNED}
   0                          // lpm_pipeline, optional, {0, 1}
 ) lpm_mult_example (
  .result                     (data_out[lpm_widthp-1:0]),
  .sum                        (partial_sum_in[lpm_widths-1:0]),  // OPTIONAL
  .dataa                      (multiplicand_a_in[lpm_widtha-1:0]),
  .datab                      (multiplicand_b_in[lpm_widthb-1:0]),
  .clock                      (clock_if_pipelined),              // OPTIONAL
  .clken                      (clock_enable_HIGH_if_pipelined),  // OPTIONAL
  .aclr                       (async_clear_if_pipelined)         // OPTIONAL
);

lpm_divide
#( 1,                         // lpm_widthn (width of numerator)
   1,                         // lpm_widthn (width of denominator)
   "UNSIGNED",                // lpm_nrepresentation, optional, {UNSIGNED, SIGNED}
   "UNSIGNED",                // lpm_drepresentation, optional, {UNSIGNED, SIGNED}
   0                          // lpm_pipeline, optional, {0, 1}
 ) lpm_divide_example (
  .quotient                   (data_out[lpm_widthn-1:0]),  // CHOICE
  .remain                     (data_out[lpm_widthd-1:0]),  // CHOICE
  .numer                      (data_out[lpm_widthn-1:0]),
  .denom                      (data_out[lpm_widthd-1:0]),
  .clock                      (clock_if_pipelined),              // OPTIONAL
  .clken                      (clock_enable_HIGH_if_pipelined),  // OPTIONAL
  .aclr                       (async_clear_if_pipelined)         // OPTIONAL
);

lpm_abs
#( 1                          // lpm_width (width of input)
 ) lpm_abs_example (
  .result                     (data_out[lpm_width-1:0]),
  .overflow                   (overflow_because_negative_number_was_max),  // OPTIONAL
  .data                       (data_in[lpm_width-1:0])
);

module lpm_counter (
#( 1,                         // lpm_width (width of input)
   0,                         // lpm_modulus (max count plus 1)
   "UNUSED",                  // lpm_direction, optional, {UNUSED, UP, DOWN}
   "UNUSED",                  // lpm_avalue, value to load if ASET active
   "UNUSED",                  // lpm_svalue, value to load if SSET active
   "UNUSED",                  // lpm_pvalue, value to load at powerup
   "lpm_counter",             // lpm_type, optional, must be "lpm_counter if lpm_hint used
   "UNUSED"                   // lpm_hint, optional, {UNSIGNED, SIGNED, BCD, GRAY_CODE, JOHNSON, LFSR}
 ) lpm_counter_example (
  .cout                       (max_value_reached),                       // CHOICE
  .q                          (counter_out[lpm_width-1:0]),              // CHOICE
  .data                       (sync_data_in[lpm_width-1:0]),             // OPTIONAL
  .sload                      (load_counter_with_data_next_clock),       // OPTIONAL
  .sset                       (set_counter_to_max_or_lpm_svalue_next_clock),  // OPTIONAL
  .sclr                       (clear_counter_next_clock),                // OPTIONAL
  .cnt_en                     (enable_counting_when_HIGH),               // OPTIONAL
  .cin                        (carry_in_to_enable_counter),              // OPTIONAL
  .updown                     (inc_if_HIGH_must_set_LOW_if_using_lpm_direction),  // OPTIONAL
  .clock                      (clock_if_pipelined),
  .clk_en                     (enable_all_sync_activity_when_HIGH),      // OPTIONAL
  .aload                      (async_load_counter_with_data),            // OPTIONAL
  .aset                       (async_set_counter_to_max_or_lpm_avalue),  // OPTIONAL
  .aclr                       (async_clear_if_pipelined)                 // OPTIONAL
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

module lpm_add_sub ( result, cout, overflow,
					 add_sub, cin, dataa, datab, clock, clken, aclr );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_direction  = "UNUSED";
	parameter lpm_representation = "UNSIGNED";
	parameter lpm_pipeline = 0;
	parameter lpm_type = "lpm_add_sub";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] dataa, datab;
	input  add_sub, cin;
	input  clock;
	input  clken;
	input  aclr;
	output [lpm_width-1:0] result;
	output cout, overflow;

	reg  [lpm_width-1:0] tmp_result;
	reg  [lpm_width-1:0] tmp_result2 [lpm_pipeline:0];
	reg  [lpm_pipeline:0] tmp_cout2;
	reg  [lpm_pipeline:0] tmp_overflow2;
	reg  tmp_cout;
	reg  tmp_overflow;
	reg  [lpm_width-1:0] tmp_a, tmp_b;
	integer i, j, k, n;
	integer dataa_int, datab_int, result_int, compare, borrow; 

	tri0 aclr;
	tri0 clock;
	tri1 clken;
	tri0 cin;
	tri1 add_sub;

	buf (i_aclr, aclr);
	buf (i_clock, clock);
	buf (i_clken, clken);
	buf (i_cin, cin);
	buf (i_add_sub, add_sub);


	always @(i_cin or dataa or datab or i_add_sub)
	begin
		borrow = i_cin ? 0 : 1;
		// cout is the same for both signed and unsign representation.  
		if (lpm_direction == "ADD" || i_add_sub == 1) 
		begin
			{tmp_cout,tmp_result} = dataa + datab + i_cin;
			tmp_overflow = tmp_cout;
		end
		else if (lpm_direction == "SUB" || i_add_sub == 0) 
		begin
			// subtraction
			{tmp_overflow, tmp_result} = dataa - datab - borrow;
			tmp_cout = (dataa >= (datab+borrow))?1:0;
		end
	
		if (lpm_representation == "SIGNED")
		begin
			// convert to negative integer
			if (dataa[lpm_width-1] == 1)
			begin
				for (j = 0; j < lpm_width; j = j + 1)
					tmp_a[j] = dataa[j] ^ 1;
				dataa_int = (tmp_a) * (-1) - 1;
			end
			else
				dataa_int = dataa;

			// convert to negative integer
			if (datab[lpm_width-1] == 1)
			begin
				for (k = 0; k < lpm_width; k = k + 1)
					tmp_b[k] = datab[k] ^ 1;
				datab_int = (tmp_b) * (-1) - 1;
			end
			else
				datab_int = datab;

			// perform the addtion or subtraction operation
			if (lpm_direction == "ADD" || i_add_sub == 1)
				result_int = dataa_int + datab_int + i_cin;
			else if (lpm_direction == "SUB" || i_add_sub == 0)
				result_int = dataa_int - datab_int - borrow;
			tmp_result = result_int;

			// set the overflow
			compare = 1 << (lpm_width -1);
			if ((result_int > (compare - 1)) || (result_int < (-1)*(compare)))
				tmp_overflow = 1;
			else
				tmp_overflow = 0;
		end
	end
	

	always @(posedge i_clock or posedge i_aclr)
	begin
		if (i_aclr)
		begin
			for (i = 0; i <= lpm_pipeline; i = i + 1)
			begin
				tmp_result2[i] = 'b0;
				tmp_cout2[i] = 1'b0;
				tmp_overflow2[i] = 1'b0;
			end
		end
		else if (i_clken == 1)
		begin
			tmp_result2[lpm_pipeline] = tmp_result;
			tmp_cout2[lpm_pipeline] = tmp_cout;
			tmp_overflow2[lpm_pipeline] = tmp_overflow;
			for (n = 0; n < lpm_pipeline; n = n + 1)
			begin
				tmp_result2[n] = tmp_result2[n+1];
				tmp_cout2[n] = tmp_cout2[n+1];
				tmp_overflow2[n] = tmp_overflow2[n+1];
			end
		end
	end


	assign result = (lpm_pipeline >0) ? tmp_result2[0]:tmp_result;
	assign cout = (lpm_pipeline >0) ? tmp_cout2[0]  : tmp_cout;
	assign overflow = (lpm_pipeline >0) ? tmp_overflow2[0] : tmp_overflow;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_add_sub") || (lpm_type !== "lpm_add_sub"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_add_sub

//------------------------------------------------------------------------

module lpm_compare ( alb, aeb, agb, aleb, aneb, ageb, dataa, datab,
					 clock, clken, aclr );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_representation = "UNSIGNED";
	parameter lpm_pipeline = 0;
	parameter lpm_type = "lpm_compare";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] dataa, datab;
	input  clock;
	input  clken;
	input  aclr;
	output alb, aeb, agb, aleb, aneb, ageb;

	reg    tmp_alb, tmp_aeb, tmp_agb;
	reg    tmp_aleb, tmp_aneb, tmp_ageb;
	reg    [lpm_pipeline:0] tmp_alb2, tmp_aeb2, tmp_agb2;
	reg    [lpm_pipeline:0] tmp_aleb2, tmp_aneb2, tmp_ageb2;
	reg    [lpm_width-1:0] a_int;
	integer i, j, k, l, m, n, o, p, u, dataa_int, datab_int;

	tri0 aclr;
	tri0 clock;
	tri1 clken;

	buf (i_aclr, aclr);
	buf (i_clock, clock);
	buf (i_clken, clken);


	always @(dataa or datab)
	begin
		if (lpm_representation == "UNSIGNED") 
		begin
			dataa_int = dataa[lpm_width-1:0];
			datab_int = datab[lpm_width-1:0];
		end
		else if (lpm_representation == "SIGNED")
		begin
			// convert to negative integer
			if (dataa[lpm_width-1] == 1)
			begin
				for (j = 0; j < lpm_width; j = j + 1)
					a_int[j] = dataa[j] ^ 1;
				dataa_int = (a_int) * (-1) - 1;
			end
			else
				dataa_int = dataa;

			// convert to negative integer
			if (datab[lpm_width-1] == 1)
			begin
				for (j = 0; j < lpm_width; j = j + 1)
					a_int[j] = datab[j] ^ 1;
				datab_int = (a_int) * (-1) - 1;
			end
			else
				datab_int = datab;
		end

		tmp_alb = (dataa_int < datab_int);
		tmp_aeb = (dataa_int == datab_int);
		tmp_agb = (dataa_int > datab_int);
		tmp_aleb = (dataa_int <= datab_int);
		tmp_aneb = (dataa_int != datab_int);
		tmp_ageb = (dataa_int >= datab_int);
	end

	always @(posedge i_clock or posedge i_aclr)
	begin
		if (i_aclr)
		begin 
			for (u = 0; u <= lpm_pipeline; u = u +1)
			begin
				tmp_aeb2[u] = 'b0;
				tmp_agb2[u] = 'b0;
				tmp_alb2[u] = 'b0;
				tmp_aleb2[u] = 'b0;
				tmp_aneb2[u] = 'b0;
				tmp_ageb2[u] = 'b0;
			end
		end
		else if (i_clken == 1)
		begin
			// Assign results to registers
			tmp_alb2[lpm_pipeline] = tmp_alb;
			tmp_aeb2[lpm_pipeline] = tmp_aeb;
			tmp_agb2[lpm_pipeline] = tmp_agb;
			tmp_aleb2[lpm_pipeline] = tmp_aleb;
			tmp_aneb2[lpm_pipeline] = tmp_aneb;
			tmp_ageb2[lpm_pipeline] = tmp_ageb;

			for (k = 0; k < lpm_pipeline; k = k +1)
				tmp_alb2[k] = tmp_alb2[k+1];
			for (l = 0; l < lpm_pipeline; l = l +1)
				tmp_aeb2[l] = tmp_aeb2[l+1];
			for (m = 0; m < lpm_pipeline; m = m +1)
				tmp_agb2[m] = tmp_agb2[m+1];
			for (n = 0; n < lpm_pipeline; n = n +1)
				tmp_aleb2[n] = tmp_aleb2[n+1];
			for (o = 0; o < lpm_pipeline; o = o +1)
				tmp_aneb2[o] = tmp_aneb2[o+1];
			for (p = 0; p < lpm_pipeline; p = p +1)
				tmp_ageb2[p] = tmp_ageb2[p+1];
		end
	end

	assign alb = (lpm_pipeline > 0) ? tmp_alb2[0] : tmp_alb;
	assign aeb = (lpm_pipeline > 0) ? tmp_aeb2[0] : tmp_aeb;
	assign agb = (lpm_pipeline > 0) ? tmp_agb2[0] : tmp_agb;
	assign aleb = (lpm_pipeline > 0) ? tmp_aleb2[0] : tmp_aleb;
	assign aneb = (lpm_pipeline > 0) ? tmp_aneb2[0] : tmp_aneb;
	assign ageb = (lpm_pipeline > 0) ? tmp_ageb2[0] : tmp_ageb;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_compare") || (lpm_type !== "lpm_compare"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_compare

//------------------------------------------------------------------------

module lpm_mult ( result, dataa, datab, sum, clock, clken, aclr );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_widtha = 1;
	parameter lpm_widthb = 1;
	parameter lpm_widths = 1;
	parameter lpm_widthp = 1;
	parameter lpm_representation  = "UNSIGNED";
	parameter lpm_pipeline  = 0;
	parameter lpm_type = "lpm_mult";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  clock;
	input  clken;
	input  aclr;
	input  [lpm_widtha-1:0] dataa;
	input  [lpm_widthb-1:0] datab;
	input  [lpm_widths-1:0] sum;
	output [lpm_widthp-1:0] result;

	// inernal reg
	reg   [lpm_widthp-1:0] tmp_result;
	reg   [lpm_widthp-1:0] tmp_result2 [lpm_pipeline:0];
	reg   [lpm_widtha-1:0] a_int;
	reg   [lpm_widthb-1:0] b_int;
	reg   [lpm_widths-1:0] s_int;
	reg   [lpm_widthp-1:0] p_reg;
	integer p_int;
	integer i, j, k, m, n, p, maxs_mn;
	integer int_dataa, int_datab, int_sum, int_result;

	tri0 aclr;
	tri0 clock;
	tri1 clken;

	buf (i_aclr, aclr);
	buf (i_clock, clock);
	buf (i_clken, clken);


	always @(dataa or datab or sum)
	begin
		if (lpm_representation == "UNSIGNED")
		begin
			int_dataa = dataa;
			int_datab = datab;
			int_sum = sum;
		end
		else if (lpm_representation == "SIGNED")
		begin
			// convert signed dataa
			if (dataa[lpm_widtha-1] == 1)
			begin
				for (i = 0; i < lpm_widtha; i = i + 1)
					a_int[i] = dataa[i] ^ 1;
				int_dataa = (a_int) * (-1) - 1;
			end
			else
				int_dataa = dataa;

			// convert signed datab
			if (datab[lpm_widthb-1] == 1)
			begin
				for (j = 0; j < lpm_widthb; j = j + 1)
					b_int[j] = datab[j] ^ 1;
				int_datab = (b_int) * (-1) - 1;
			end
			else
				int_datab = datab;

			// convert signed sum
			if (sum[lpm_widths-1] == 1)
			begin
				for (k = 0; k < lpm_widths; k = k + 1)
					s_int[k] = sum[k] ^ 1;
				int_sum = (s_int) * (-1) - 1;
			end
			else
				int_sum = sum;
		end
		else 
		begin
			int_dataa = {lpm_widtha{1'bx}};
			int_datab = {lpm_widthb{1'bx}};
			int_sum   = {lpm_widths{1'bx}};
		end

		p_int = int_dataa * int_datab + int_sum;
		maxs_mn = ((lpm_widtha+lpm_widthb)>lpm_widths)?lpm_widtha+lpm_widthb:lpm_widths;
		if (lpm_widthp >= maxs_mn)
			tmp_result = p_int;
		else
		begin
			p_reg = p_int;
			for (m = 0; m < lpm_widthp; m = m + 1)
				tmp_result[lpm_widthp-1-m] = p_reg[maxs_mn-1-m];
		end 
	end

	always @(posedge i_clock or posedge i_aclr)
	begin
	  if (i_aclr)
		begin
			for (p = 0; p <= lpm_pipeline; p = p + 1)
				tmp_result2[p] = 'b0;
		end
	  else if (i_clken == 1)
	  begin :syn_block
		tmp_result2[lpm_pipeline] = tmp_result;
		for (n = 0; n < lpm_pipeline; n = n +1)
			tmp_result2[n] = tmp_result2[n+1];
	  end
	end

  assign result = (lpm_pipeline > 0) ? tmp_result2[0] : tmp_result;

// Check for previous Parameter declaration order
initial if ((lpm_widtha === "lpm_mult") || (lpm_type !== "lpm_mult"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_mult

//------------------------------------------------------------------------

module lpm_divide ( quotient,remain, numer, denom, clock, clken, aclr );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_widthn = 1;
	parameter lpm_widthd = 1;
	//parameter lpm_widthq = 1;
	//parameter lpm_widthr = 1;
	parameter lpm_nrepresentation = "UNSIGNED";
	parameter lpm_drepresentation = "UNSIGNED";
	parameter lpm_pipeline = 0;
	parameter lpm_type = "lpm_divide";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  clock;
	input  clken;
	input  aclr;
	input  [lpm_widthn-1:0] numer;
	input  [lpm_widthd-1:0] denom;
	output [lpm_widthn-1:0] quotient;
	output [lpm_widthd-1:0] remain;

	// inernal reg
	reg   [lpm_widthn-1:0] tmp_quotient [lpm_pipeline:0];
	reg   [lpm_widthd-1:0] tmp_remain [lpm_pipeline:0];
	reg   [lpm_widthn-1:0] ONES, ZEROS, UNKNOWN, HiZ;
	reg   [lpm_widthd-1:0] DZEROS, DUNKNOWN;
	reg   [lpm_widthn-1:0] NUNKNOWN;
	reg   [lpm_widthd-1:0] RZEROS ;
	integer i;
	integer int_numer, int_denom, int_quotient, int_remain;

	tri0 aclr;
	tri0 clock;
	tri1 clken;

	buf (i_aclr, aclr);
	buf (i_clock, clock);
	buf (i_clken, clken);


	initial
	begin

	// check if lpm_widthn > 0
	if (lpm_widthn <= 0)
		$display("%t: Error! LPM_WIDTHN must be greater than 0.\n", $time);
	// check if lpm_widthd > 0
	if (lpm_widthd <= 0)
		$display("%t: Error! LPM_WIDTHD must be greater than 0.\n", $time);
	// check if lpm_widthn > 0
		//if (lpm_widthq <= 0)
		//    $display("%t: Error! LPM_WIDTHQ must be greater than 0.\n", $time);
	// check if lpm_widthR > 0
		//if (lpm_widthr <= 0)
		//    $display("%t: Error! LPM_WIDTHR must be greater than 0.\n", $time);
	// check for valid lpm_nrep value
	if ((lpm_nrepresentation !== "SIGNED") && (lpm_nrepresentation !== "UNSIGNED"))
		$display("%t: Error! LPM_NREPRESENTATION value must be \"SIGNED\" or \"UNSIGNED\".", $time);

	// check for valid lpm_drep value
	if ((lpm_drepresentation !== "SIGNED") && (lpm_drepresentation !== "UNSIGNED"))
		$display("%t: Error! LPM_DREPRESENTATION value must be \"SIGNED\" or \"UNSIGNED\".", $time);

	// check if lpm_pipeline is > 1 and clock is not used
	if ((lpm_pipeline >=1) && (clock === 1'bz))
		$display("%t: Error! The clock pin is requied if lpm_pipeline is used\n", $time);
	else if ((lpm_pipeline == 0) && (clock !== 1'bz))
		$display("%t: Error! If the clock pin is used, lpm_pipeline must be greater than 0.\n", $time);
	
	for (i=0; i < lpm_widthn; i=i+1)
	begin
		ONES[i] = 1'b1;
		ZEROS[i] = 1'b0;
		UNKNOWN[i] = 1'bx;
		HiZ[i] = 1'bz;
	end

	for (i=0; i < lpm_widthd; i=i+1)
		DUNKNOWN[i] = 1'bx;

	for (i=0; i < lpm_widthn; i=i+1)
		NUNKNOWN[i] = 1'bx;

	for (i=0; i < lpm_widthd; i=i+1)
		RZEROS[i] = 1'b0;

	end

	always @(numer or denom)
	begin
		if (lpm_nrepresentation == "UNSIGNED")
			int_numer = numer;
		else if (lpm_nrepresentation == "SIGNED")
		begin
			// convert signed numer
			if (numer[lpm_widthn-1] == 1)
			begin
				int_numer = 0;
				for (i = 0; i < lpm_widthn - 1; i = i + 1)
					int_numer[i] = numer[i] ^ 1;
				int_numer = -(int_numer + 1);
			end
			else
				int_numer = numer;
		end
		else 
			int_numer = NUNKNOWN;

		if (lpm_drepresentation == "UNSIGNED")
			int_denom = denom;
		else if (lpm_drepresentation == "SIGNED")
		begin
			// convert signed denom
			if (denom[lpm_widthd-1] == 1)
			begin
				int_denom = 0;
				for (i = 0; i < lpm_widthd - 1; i = i + 1)
					int_denom[i] = denom[i] ^ 1;
				int_denom = -(int_denom + 1);
			end
			else
				int_denom = denom;
		end
		else 
			int_denom = DUNKNOWN;

		int_quotient = int_numer / int_denom;
		int_remain = int_numer % int_denom;

		tmp_quotient[lpm_pipeline] = int_quotient;
		tmp_remain[lpm_pipeline] = int_remain;
	end

	always @(posedge i_clock or i_aclr)
	begin :syn_block
		if (i_aclr)
		begin
			disable syn_block;
			for (i = 0; i <= lpm_pipeline; i = i + 1)
				tmp_quotient[i] = ZEROS;
			tmp_remain[i] = RZEROS;
		end
		else if (i_clken)
			for (i = 0; i < lpm_pipeline; i = i +1)
			begin
				tmp_quotient[i] = tmp_quotient[i+1];
				tmp_remain[i] = tmp_remain[i+1];
			end
	end

	assign quotient = tmp_quotient[0];
	assign remain = tmp_remain[0];

// Check for previous Parameter declaration order
initial if ((lpm_widthn === "lpm_divide") || (lpm_type !== "lpm_divide"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_divide

//------------------------------------------------------------------------

module lpm_abs ( result, overflow, data );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_type = "lpm_abs";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	output [lpm_width-1:0] result;
	output overflow;

	reg    [lpm_width-1:0] a_int;
	reg    [lpm_width-1:0] result;
	reg    overflow;
	integer i;

	always @(data)
	begin
		overflow = 0;
		if (data[lpm_width-1] == 1)
		begin
			for (i = 0; i < lpm_width; i = i + 1)
				a_int[i] = data[i] ^ 1;
			result = (a_int + 1);
			overflow = (result == ( 1<<(lpm_width -1)));
		end
		else
			result = data;
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_abs") || (lpm_type !== "lpm_abs"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_abs

//------------------------------------------------------------------------

module lpm_counter ( q, data, clock, cin, cout,clk_en, cnt_en, updown,
					 aset, aclr, aload, sset, sclr, sload );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_modulus = 0;
	parameter lpm_direction = "UNUSED";
	parameter lpm_avalue = "UNUSED";
	parameter lpm_svalue = "UNUSED";
	parameter lpm_pvalue = "UNUSED";
	parameter lpm_type = "lpm_counter";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	output [lpm_width-1:0] q;
	//output [lpm_modulus-1:0] eq;
	output cout;
	input  cin;
	input  [lpm_width-1:0] data;
	input  clock, clk_en, cnt_en, updown;
	input  aset, aclr, aload;
	input  sset, sclr, sload;

	reg  [lpm_width-1:0] tmp_count;
	reg  tmp_updown;
	integer tmp_modulus;

	tri1 clk_en;
	tri1 cnt_en;
	tri1 updown;
	tri0 sload;
	tri0 sset;
	tri0 sclr;
	tri0 aload;
	tri0 aset;
	tri0 aclr;
	tri0 cin;

	buf (i_clk_en, clk_en);
	buf (i_cnt_en, cnt_en);
	buf (i_updown, updown);
	buf (i_sload, sload);
	buf (i_sset, sset);
	buf (i_sclr, sclr);
	buf (i_aload, aload);
	buf (i_aset, aset);
	buf (i_aclr, aclr);
	buf (i_cin, cin);


//---------------------------------------------------------------//
	function [lpm_width-1:0] NextBin;
		input [lpm_width-1:0] count;
		
		//reg  [lpm_width-1:0] re_start;
		//reg  [lpm_width-1:0] tmp_nextbin;
		//integer up_limit;
		
		begin 
			if (tmp_updown == 1)
			begin
				if (i_cin == 1 && count == tmp_modulus-2)
					NextBin = 0;
				else
					NextBin = (count >= tmp_modulus-1) ? i_cin : count+1+i_cin;
			end
			else
			begin
				if (i_cin == 1 && count == 1)
					NextBin = tmp_modulus - 1;
				else
					NextBin = (count <= 0) ? tmp_modulus-1-i_cin : count-1-i_cin;
			end
		end 
	endfunction

//---------------------------------------------------------------//
//  function [(1<<lpm_width)-1:0] CountDecode;
//---------------------------------------------------------------//
//  function [lpm_modulus:0] CountDecode;
//      input [lpm_width-1:0] count;
//
//      integer eq_index;
//
//      begin
//          CountDecode = 0;
//          eq_index = 0;
//          if (count < lpm_modulus)
//          begin
//              eq_index = count;
//              CountDecode[eq_index] = 1'b1;
//          end
//      end
//  endfunction

//---------------------------------------------------------------//
//  function integer str_to_int;
//---------------------------------------------------------------//
	function integer str_to_int;
		input  [8*16:1] s; 

		reg [8*16:1] reg_s;
		reg [8:1] digit;
		reg [8:1] tmp;
		integer m, ivalue;
		
		begin
			ivalue = 0;
			reg_s = s;
			for (m=1; m<=16; m=m+1)
			begin 
				tmp = reg_s[128:121];
				digit = tmp & 8'b00001111;
				reg_s = reg_s << 8; 
				ivalue = ivalue * 10 + digit; 
			end
			str_to_int = ivalue;
		end
	endfunction

//---------------------------------------------------------------//

	initial
	begin
		// check if lpm_modulus < 0
		if (lpm_modulus < 0)
			$display("%t: Error! LPM_MODULUS must be greater than 0.\n", $time);
		// check if lpm_modulus > 1<<lpm_width
		if (lpm_modulus > 1<<lpm_width)
			$display("%t: Error! LPM_MODULUS must be less than or equal to 1<<LPM_WIDTH.\n", $time);

		if (lpm_direction == "UNUSED")
			tmp_updown = (i_updown == 0) ? 0 : 1;
		else
			tmp_updown = (lpm_direction == "DOWN") ? 0 : 1;

		tmp_modulus = (lpm_modulus == 0) ? (1 << lpm_width) : lpm_modulus;
		tmp_count = (lpm_pvalue == "UNUSED") ? 0 : str_to_int(lpm_pvalue);
	end

	always @(i_updown)
	begin
		if (lpm_direction == "UNUSED")
			tmp_updown = (i_updown == 0) ? 0 : 1;
		else
			$display("%t: Error! LPM_DIRECTION and UPDOWN cannot be used at the same time.\n", $time);
	end

	always @(posedge clock or posedge i_aclr or posedge i_aset or
			  posedge i_aload)
	begin :asyn_block
		if (i_aclr)
			tmp_count = 0;
		else if (i_aset)
			tmp_count = (lpm_avalue == "UNUSED") ? {lpm_width{1'b1}}
												 : str_to_int(lpm_avalue);
		else if (i_aload)
			tmp_count = data;
		else
		begin :syn_block
			if (i_clk_en)
			begin
				if (i_sclr)
					tmp_count = 0;
				else if (i_sset)
					tmp_count = (lpm_svalue == "UNUSED") ? {lpm_width{1'b1}}
														 : str_to_int(lpm_svalue);
				else if (i_sload)
					tmp_count = data;
				else if (i_cnt_en)
					tmp_count = NextBin(tmp_count);
			end
		end
	end 

	assign q =  tmp_count;
	//assign eq = CountDecode(tmp_count);
	assign cout = (((tmp_count >= tmp_modulus-1-i_cin) && tmp_updown)
				  || ((tmp_count <= i_cin) && !tmp_updown)) ? 1 : 0;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_counter") || (lpm_type !== "lpm_counter"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_counter
