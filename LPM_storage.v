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

lpm_latch
#( 1,                         // lpm_width
   "UNUSED",                  // lpm_avalue, aset value, optional, -1 if not set
   "UNUSED"                   // lpm_pvalue, power-up value, optional
 ) lpm_latch_example (
  .q                          (data_out[lpm_width-1:0]),
  .data                       (data_in[lpm_width-1:0]),
  .gate                       (pass_thru_when_HIGH),
  .aset                       (set_to_aset_value_when_HIGH),  // OPTIONAL
  .aclr                       (set_to_zero_when_HIGH)         // OPTIONAL
);

lpm_ff
#( 1,                         // lpm_width
   "UNUSED",                  // lpm_avalue, aset value, optional, -1 if not set
   "UNUSED",                  // lpm_svalue, sset value, optional, -1 if not set
   "UNUSED",                  // lpm_pvalue, power-up value, optional
   "DFF"                      // lpm_fftype, optional, {DFF, TFF}
 ) lpm_ff_example (
  .q                          (data_out[lpm_width-1:0]),
  .data                       (data_in[lpm_width-1:0]),
  .clock                      (rising_edge_flop_clock),
  .enable                     (clock_enable_when_HIGH),            // OPTIONAL
  .sload                      (load_data_to_toggle_flops_if_TFF),  // OPTIONAL
  .sset                       (load_data_from_svalue_if_HIGH),     // OPTIONAL
  .sclr                       (set_value_to_0_if_HIGH),            // OPTIONAL
  .aload                      (load_data_to_toggle_flops_if_TFF),  // OPTIONAL
  .aset                       (load_data_from_svalue_if_HIGH),     // OPTIONAL
  .aclr                       (set_value_to_0_if_HIGH)             // OPTIONAL
);

lpm_shiftreg
#( 1,                         // lpm_width
   "UNUSED",                  // lpm_avalue, aset value, optional, -1 if not set
   "UNUSED",                  // lpm_svalue, sset value, optional, -1 if not set
   "UNUSED",                  // lpm_pvalue, power-up value, optional
   "LEFT"                     // lpm_direction, optional, {LEFT, RIGHT}
 ) lpm_shiftreg_example (
  .q                          (data_out[lpm_width-1:0]),
  .shiftout                   (shift_data_from_LSB_or_MSB),
  .data                       (parallel_data_in[lpm_width-1:0]), // OPTIONAL
  .shiftin                    (shift_data_to_LSB_or_MSB),
  .clock                      (rising_edge_flop_clock),
  .enable                     (clock_enable_when_HIGH),          // OPTIONAL
  .load                       (parallel_load_data_when_HIGH),    // OPTIONAL
  .sset                       (load_data_from_svalue_if_HIGH),   // OPTIONAL
  .sclr                       (set_value_to_0_if_HIGH),          // OPTIONAL
  .aset                       (load_data_from_svalue_if_HIGH),   // OPTIONAL
  .aclr                       (set_value_to_0_if_HIGH)           // OPTIONAL
);

lpm_ram_dq
#( 1,                         // lpm_width
	parameter lpm_widthad = 1;
	parameter lpm_numwords = 1 << lpm_widthad;
	parameter lpm_indata = "REGISTERED";
	parameter lpm_address_control = "REGISTERED";
	parameter lpm_outdata = "REGISTERED";
	parameter lpm_file = "UNUSED";
 ) lpm_ram_dq_example (
  .q                          (data_out[lpm_width-1:0]),
  .data                       (parallel_data_in[lpm_width-1:0]),
);
// NOTE: WORKING
( q, data, inclock, outclock, we, address );

	input  [lpm_width-1:0] data;
	input  [lpm_widthad-1:0] address;
	input  inclock, outclock, we;
	output [lpm_width-1:0] q;


lpm_ram_dp
#( 1,                         // lpm_width
	parameter lpm_widthad = 1;
	parameter lpm_numwords = 1<< lpm_widthad;
	parameter lpm_indata = "REGISTERED";
	parameter lpm_outdata = "REGISTERED";
	parameter lpm_rdaddress_control  = "REGISTERED";
	parameter lpm_wraddress_control  = "REGISTERED";
	parameter lpm_file = "UNUSED";
 ) lpm_ram_dp_example (
  .q                          (data_out[lpm_width-1:0]),
  .data                       (parallel_data_in[lpm_width-1:0]),
);
( q, data, wraddress, rdaddress, rdclock, wrclock, rdclken, wrclken, rden, wren);

	input  [lpm_width-1:0] data;
	input  [lpm_widthad-1:0] rdaddress, wraddress;
	input  rdclock, wrclock, rdclken, wrclken, rden, wren;
	output [lpm_width-1:0] q;


lpm_ram_io
#( 1,                         // lpm_width
	parameter lpm_widthad = 1;
	parameter lpm_numwords = 1<< lpm_widthad;
	parameter lpm_indata = "REGISTERED";
	parameter lpm_address_control = "REGISTERED";
	parameter lpm_outdata = "REGISTERED";
	parameter lpm_file = "UNUSED";
 ) lpm_ram_io_example (
  .q                          (data_out[lpm_width-1:0]),
  .data                       (parallel_data_in[lpm_width-1:0]),
);
( dio, inclock, outclock, we, memenab, outenab, address );

	input  [lpm_widthad-1:0] address;
	input  inclock, outclock, we;
	input  memenab;
	input  outenab;
	inout  [lpm_width-1:0] dio;

lpm_rom
#( 1,                         // lpm_width
	parameter lpm_widthad = 1;
	parameter lpm_numwords = 1<< lpm_widthad;
	parameter lpm_address_control = "REGISTERED";
	parameter lpm_outdata = "REGISTERED";
	parameter lpm_file = "rom.hex";
 ) lpm_rom_example (
  .q                          (data_out[lpm_width-1:0]),
  .data                       (parallel_data_in[lpm_width-1:0]),
);
( q, inclock, outclock, memenab, address );

	input  [lpm_widthad-1:0] address;
	input  inclock, outclock;
	input  memenab;
	output [lpm_width-1:0] q;

lpm_fifo
#( 1,                         // lpm_width
	parameter lpm_widthu  = 1;
	parameter lpm_numwords = 2;
	parameter lpm_showahead = "OFF";
 ) lpm_fifo_example (
  .q                          (data_out[lpm_width-1:0]),
  .data                       (parallel_data_in[lpm_width-1:0]),
);
(data, clock, wrreq, rdreq, aclr, sclr, q, usedw, full, empty);

	input [lpm_width-1:0] data;
	input clock;
	input wrreq;
	input rdreq;
	input aclr;
	input sclr;
	output [lpm_width-1:0] q;
	output [lpm_widthu-1:0] usedw;
	output full;
	output empty;


lpm_fifo_dc
#( 1,                         // lpm_width
	parameter lpm_widthu = 1;
	parameter lpm_numwords = 2;
	parameter lpm_showahead = "OFF";
 ) lpm_fifo_dc_example (
  .q                          (data_out[lpm_width-1:0]),
  .data                       (parallel_data_in[lpm_width-1:0]),
);
( data, rdclock, wrclock, aclr, rdreq, wrreq, rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q );

	input [lpm_width-1:0] data;
	input rdclock;
	input wrclock;
	input wrreq;
	input rdreq;
	input aclr;
	output rdfull;
	output wrfull;
	output rdempty;
	output wrempty;
	output [lpm_width-1:0] q;
	output [lpm_widthu-1:0] rdusedw;
	output [lpm_widthu-1:0] wrusedw;

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

module lpm_latch ( q, data, gate, aset, aclr );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_avalue = "UNUSED";
	parameter lpm_pvalue = "UNUSED";
	parameter lpm_type = "lpm_latch";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	input  gate, aset, aclr;
	output [lpm_width-1:0] q;

	reg [lpm_width-1:0] q;

	tri0 aset;
	tri0 aclr;

	buf (i_aset, aset);
	buf (i_aclr, aclr);

//---------------------------------------------------------------//
//  function integer str_to_int;
//---------------------------------------------------------------//
	function integer str_to_int;
		input  [8*16:1] s; 
		
		reg [8*16:1] reg_s;
		reg [8:1] digit;
		reg [8:1] tmp;
		integer m , ivalue; 
		
		begin 
			ivalue = 0;
			reg_s = s;
			for (m=1; m<=16; m= m+1) 
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
		if (lpm_pvalue != "UNUSED")
			q = str_to_int(lpm_pvalue);
	end

	always @(data or gate or i_aclr or i_aset)
	begin
		if (i_aclr)
			q = 'b0;
		else if (i_aset)
			begin
				if (lpm_avalue == "UNUSED")
					q = {lpm_width{1'b1}};
				else    
					q = str_to_int(lpm_avalue);
			end
		else if (gate)
			q = data;
	end

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_latch") || (lpm_type !== "lpm_latch"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_latch

//------------------------------------------------------------------------

module lpm_ff ( q, data, clock, enable, aclr, aset,
				sclr, sset, aload, sload );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width  = 1;
	parameter lpm_avalue = "UNUSED";
	parameter lpm_svalue = "UNUSED";
	parameter lpm_pvalue = "UNUSED";
	parameter lpm_fftype = "DFF";
	parameter lpm_type = "lpm_ff";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";


	input  [lpm_width-1:0] data;
	input  clock, enable;
	input  aclr, aset;
	input  sclr, sset;
	input  aload, sload ;
	output [lpm_width-1:0] q;

	reg   [lpm_width-1:0] tmp_q;
	integer i;

	tri1 enable;
	tri0 sload;
	tri0 sclr;
	tri0 sset;
	tri0 aload;
	tri0 aclr;
	tri0 aset;
	  
	buf (i_enable, enable);
	buf (i_sload, sload);
	buf (i_sclr, sclr);
	buf (i_sset, sset);
	buf (i_aload, aload);
	buf (i_aclr, aclr);
	buf (i_aset, aset);

//---------------------------------------------------------------//
//  function integer str_to_int;
//---------------------------------------------------------------//
	function integer str_to_int;
		input  [8*16:1] s; 
		
		reg [8*16:1] reg_s;
		reg [8:1]   digit;
		reg [8:1] tmp;
		integer   m , ivalue; 
		
		begin
			ivalue = 0;
			reg_s = s;
			for (m=1; m<=16; m= m+1) 
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
		if (lpm_pvalue != "UNUSED")
			tmp_q = str_to_int(lpm_pvalue);
	end

	always @(posedge clock or posedge i_aclr or posedge i_aset or
			  posedge i_aload)
	begin :asyn_block // Asynchronous process
		if (i_aclr)
		begin
			 tmp_q = 0;
		end
		else if (i_aset)
		begin
			if (lpm_avalue == "UNUSED")
				tmp_q = {lpm_width{1'b1}};
			else
				tmp_q = str_to_int(lpm_avalue);
		end
		else if (i_aload)
		begin
				 tmp_q = data;
		end
		else
		begin :syn_block // Synchronous process
			if (i_enable)
			begin
				if (i_sclr)
				begin
					tmp_q = 0;
				end
				else if (i_sset)
				begin
					if (lpm_svalue == "UNUSED") 
						tmp_q = {lpm_width{1'b1}}; 
					else
						tmp_q = str_to_int(lpm_svalue);
				end
				else if (i_sload)  // Load data
				begin
					tmp_q = data;
				end
				else
				begin
					if (lpm_fftype == "TFF") // toggle
					begin
						for (i = 0; i < lpm_width; i=i+1)
						begin
							if (data[i] == 1'b1) 
								tmp_q[i] = ~tmp_q[i];
						end
					end
					else 
					if (lpm_fftype == "DFF") // load data
						tmp_q = data;
				end
			end
		end
	end

	assign q = tmp_q;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_ff") || (lpm_type !== "lpm_ff"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_ff
 
//------------------------------------------------------------------------

module lpm_shiftreg ( q, shiftout, data, clock, enable, aclr, aset, 
					  sclr, sset, shiftin, load );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width  = 1;
	parameter lpm_avalue = "UNUSED";
	parameter lpm_svalue = "UNUSED";
	parameter lpm_pvalue = "UNUSED";
	parameter lpm_direction = "LEFT";
	parameter lpm_type = "lpm_shiftreg";
	parameter lpm_hint  = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	input  clock, enable;
	input  aclr, aset;
	input  sclr, sset;
	input  shiftin, load;
	output [lpm_width-1:0] q;
	output shiftout;

	reg  [lpm_width-1:0] tmp_q;
	reg  abit;
	integer i;

	wire tmp_shiftout;

	tri1 enable;
	tri1 shiftin;
	tri0 load;
	tri0 sclr;
	tri0 sset;
	tri0 aclr;
	tri0 aset;

	buf (i_enable, enable);
	buf (i_shiftin, shiftin);
	buf (i_load, load);
	buf (i_sclr, sclr);
	buf (i_sset, sset);
	buf (i_aclr, aclr);
	buf (i_aset, aset);


//---------------------------------------------------------------//
//  function integer str_to_int;
//---------------------------------------------------------------//
	function integer str_to_int;
		input  [8*16:1] s; 

		reg [8*16:1] reg_s;
		reg [8:1]   digit;
		reg [8:1] tmp;
		integer   m , ivalue; 

		begin 
			ivalue = 0;
			reg_s = s;
			for (m=1; m<=16; m= m+1) 
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
		if (lpm_pvalue != "UNUSED")
			tmp_q = str_to_int(lpm_pvalue);
	end

	always @(posedge clock or posedge i_aclr or posedge i_aset)
	begin :asyn_block // Asynchronous process
		if (i_aclr)
		begin
			tmp_q = 0;
		end
		else if (i_aset)
		begin
			if (lpm_avalue === "UNUSED")
				tmp_q = {lpm_width{1'b1}};
			else
				tmp_q = str_to_int(lpm_avalue);
		end
		else
		begin :syn_block // Synchronous process
			if (i_enable)
			begin
				if (i_sclr)
				begin
					tmp_q = 0;
				end
				else if (i_sset)
				begin
					if (lpm_svalue === "UNUSED")
						tmp_q = {lpm_width{1'b1}};
					else
						tmp_q = str_to_int(lpm_svalue);
				end
				else if (i_load)  
				begin
					tmp_q = data;
				end
				else if (!i_load)
				begin
					if (lpm_direction === "LEFT")
					begin
						{abit,tmp_q} = {tmp_q,i_shiftin};
					end
					else if (lpm_direction === "RIGHT")
					begin
						{tmp_q,abit} = {i_shiftin,tmp_q};
					end
				end
			end
		end
	end


	assign tmp_shiftout = (lpm_direction === "LEFT") ? tmp_q[lpm_width-1]
													 : tmp_q[0];
	assign q = tmp_q;
	assign shiftout = tmp_shiftout;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_shiftreg") || (lpm_type !== "lpm_shiftreg"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_shiftreg
 
//------------------------------------------------------------------------

module lpm_ram_dq ( q, data, inclock, outclock, we, address );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_widthad = 1;
	parameter lpm_numwords = 1 << lpm_widthad;
	parameter lpm_indata = "REGISTERED";
	parameter lpm_address_control = "REGISTERED";
	parameter lpm_outdata = "REGISTERED";
	parameter lpm_file = "UNUSED";
	parameter lpm_type = "lpm_ram_dq";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	input  [lpm_widthad-1:0] address;
	input  inclock, outclock, we;
	output [lpm_width-1:0] q;


  // internal reg 
	reg  [lpm_width-1:0] mem_data [lpm_numwords-1:0];
	reg  [lpm_width-1:0] tmp_q;
	reg  [lpm_width-1:0] pdata;
	reg  [lpm_width-1:0] in_data;
	reg  [lpm_widthad-1:0] paddress;
	reg  pwe;
	reg  [lpm_width-1:0]  ZEROS, UNKNOWN;
	reg  [8*256:1] ram_initf;
	integer i;

	tri0 inclock;
	tri0 outclock;

	buf (i_inclock, inclock);
	buf (i_outclock, outclock);

//---------------------------------------------------------------//
	function ValidAddress;
		input [lpm_widthad-1:0] paddress;

		begin
			ValidAddress = 1'b0;
			if (^paddress ==='bx)
				$display("%d:Error! Invalid address.\n", $time);
			else if (paddress >= lpm_numwords)
				$display("%d:Error! Address out of bound on RAM.\n", $time);
			else
				ValidAddress = 1'b1;
		end
  endfunction
//---------------------------------------------------------------//
		
	initial
	begin

		// Initialize the internal data register.
		pdata = 0;
		paddress = 0;
		pwe = 0;
		tmp_q = 0;

		if (lpm_width <= 0)
			$display("Error! lpm_width parameter must be greater than 0.");

		if (lpm_widthad <= 0)
			$display("Error! lpm_widthad parameter must be greater than 0.");
		// check for number of words out of bound
		if ((lpm_numwords > (1 << lpm_widthad))
			||(lpm_numwords <= (1 << (lpm_widthad-1))))
		begin
			$display("Error! lpm_numwords must equal to the ceiling of log2(lpm_widthad).");
	 
		end
	 
		if ((lpm_indata !== "REGISTERED") && (lpm_indata !== "UNREGISTERED"))
		begin
			$display("Error! lpm_indata must be REGISTERED (the default) or UNREGISTERED.");
		end
		
		if ((lpm_address_control !== "REGISTERED") && (lpm_address_control !== "UNREGISTERED"))
		begin
			$display("Error! lpm_address_control must be REGISTERED (the default) or UNREGISTERED.");
		end
		
		if ((lpm_outdata !== "REGISTERED") && (lpm_outdata !== "UNREGISTERED"))
		begin
			$display("Error! lpm_outdata must be REGISTERED (the default) or UNREGISTERED.");
		end  

		// check if lpm_indata or lpm_address_control is set to registered
		// inclock must be used.
		if (((lpm_indata === "REGISTERED") || (lpm_address_control === "REGISTERED")) && (inclock === 1'bz))
		begin
			$display("Error! inclock = 1'bz. Inclock pin must be used.\n");
		end

		// check if lpm_outdata, outclock must be used
		if ((lpm_outdata === "REGISTERED") && (outclock === 1'bz))
		begin
			$display("Error! lpm_outdata = REGISTERED, outclock = 1'bz . Outclock pin must be used.\n");
		end

		for (i=0; i < lpm_width; i=i+1)
		begin
			ZEROS[i] = 1'b0;
			UNKNOWN[i] = 1'bX;
		end 
		
		for (i = 0; i < lpm_numwords; i=i+1)
			mem_data[i] = ZEROS;

		// load data to the RAM
		if (lpm_file != "UNUSED")
		begin
			$convert_hex2ver(lpm_file, lpm_width, ram_initf);
			$readmemh(ram_initf, mem_data);
		end 

	end

		
	always @(posedge i_inclock)
	begin
		if ((lpm_indata === "REGISTERED") && (lpm_address_control === "REGISTERED"))
		begin
			paddress <= address;
			pdata <= data;
			pwe <= we;
		end
		else
		begin
			if ((lpm_indata === "REGISTERED") && (lpm_address_control === "UNREGISTERED"))
				pdata <= data;

			if ((lpm_indata === "UNREGISTERED") && (lpm_address_control === "REGISTERED"))
			begin
				paddress <= address;
				pwe <= we;
			end
		end
	end

	always @(data)
	begin
		if (lpm_indata === "UNREGISTERED")
			pdata <= data;
	end
	
	always @(address)
	begin
		if (lpm_address_control === "UNREGISTERED")
			paddress <= address;
	end
	
	always @(we)
	begin
		if (lpm_address_control === "UNREGISTERED")
			pwe <= we;
	end
	
	always @(pdata or paddress or pwe)
	begin :unregistered_inclock
		if (ValidAddress(paddress))
		begin
			if ((lpm_indata === "UNREGISTERED" && lpm_address_control === "UNREGISTERED") || (lpm_address_control === "UNREGISTERED"))
			begin
				if (pwe)
					mem_data[paddress] <= pdata;
			end

		end
		else
		begin
			if (lpm_outdata === "UNREGISTERED")
				tmp_q <= UNKNOWN;
		end
	end

	always @(posedge i_outclock)
	begin
		if (lpm_outdata === "REGISTERED")
		begin
			if (ValidAddress(paddress))
				tmp_q <= mem_data[paddress];
			else
				tmp_q <= UNKNOWN;
		end
	end
 
	always @(negedge i_inclock)
	begin
		if (lpm_address_control === "REGISTERED")
		begin
			if (pwe)
				mem_data[paddress] <= pdata;
		end
	end

	assign q = ( lpm_outdata === "UNREGISTERED" ) ? mem_data[paddress] : tmp_q;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_ram_dq") || (lpm_type !== "lpm_ram_dq"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_ram_dq
 
//------------------------------------------------------------------------

module lpm_ram_dp ( q, data, wraddress, rdaddress, rdclock, wrclock, rdclken, wrclken, rden, wren);

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_widthad = 1;
	parameter lpm_numwords = 1<< lpm_widthad;
	parameter lpm_indata = "REGISTERED";
	parameter lpm_outdata = "REGISTERED";
	parameter lpm_rdaddress_control  = "REGISTERED";
	parameter lpm_wraddress_control  = "REGISTERED";
	parameter lpm_file = "UNUSED";
	parameter lpm_type = "lpm_ram_dp";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_width-1:0] data;
	input  [lpm_widthad-1:0] rdaddress, wraddress;
	input  rdclock, wrclock, rdclken, wrclken, rden, wren;
	output [lpm_width-1:0] q;


	// internal reg 
	reg  [lpm_width-1:0] mem_data [lpm_numwords-1:0];
	reg  [lpm_width-1:0] tmp_q;
	reg  [lpm_width-1:0] prev_q;
	reg  [lpm_width-1:0] new_data;
	reg  [lpm_widthad-1:0] new_raddress;
	reg  [lpm_widthad-1:0] new_wraddress;
	reg  wren_event, rden_event;
	reg  [lpm_width-1:0]  ZEROS, UNKNOWN;
	reg  [8*256:1] ram_initf;
	integer i;

	tri0 rdclock;
	tri1 rdclken;
	tri1 rden;
	tri0 wrclock;
	tri1 wrclken;
			   
	buf (i_rdclock, rdclock);
	buf (i_rdclken, rdclken);
	buf (i_rden, rden);
	buf (i_wrclock, wrclock);
	buf (i_wrclken, wrclken);


//---------------------------------------------------------------//
	function ValidAddress;
		input [lpm_widthad-1:0] paddress;
	
		begin
			ValidAddress = 1'b0;
			if (^paddress ==='bx)
				$display("%d:Error! Invalid address.\n", $time);
			else if (paddress >= lpm_numwords)
				$display("%d:Error! Address out of bound on RAM.\n", $time);
			else
				ValidAddress = 1'b1;
		end
	endfunction
//---------------------------------------------------------------//
		
	initial
	begin

		// Initialize the internal data register.
		new_data = 0;
		new_raddress = 0;
		new_wraddress = 0;
		wren_event = 0;
		tmp_q = 0;

		if (lpm_width <= 0)
			$display("Error! lpm_width parameter must be greater than 0.");

		if (lpm_widthad <= 0)
			$display("Error! lpm_widthad parameter must be greater than 0.");
		// check for number of words out of bound
		if ((lpm_numwords > (1 << lpm_widthad))
			||(lpm_numwords <= (1 << (lpm_widthad-1))))
		begin
			$display("Error! lpm_numwords must equal to the ceiling of log2(lpm_widthad).");
		end
			 
		if ((lpm_indata !== "REGISTERED") && (lpm_indata !== "UNREGISTERED"))
		begin
			$display("Error! lpm_indata must be REGISTERED (the default) or UNREGISTERED.");
		end
				
		if ((lpm_rdaddress_control !== "REGISTERED") && (lpm_rdaddress_control !== "UNREGISTERED"))
		begin
			$display("Error! lpm_rdaddress_control must be REGISTERED (the default) or UNREGISTERED.");
		end
				
		if ((lpm_wraddress_control !== "REGISTERED") && (lpm_wraddress_control !== "UNREGISTERED"))
		begin
			$display("Error! lpm_wraddress_control must be REGISTERED (the default) or UNREGISTERED.");
		end
				
		if ((lpm_outdata !== "REGISTERED") && (lpm_outdata !== "UNREGISTERED"))
		begin
			$display("Error! lpm_outdata must be REGISTERED (the default) or UNREGISTERED.");
		end  

		// check if lpm_indata or lpm_wraddress_control is set to registered
		// wrclock and wrclken must be used.
		if (((lpm_indata === "REGISTERED") || (lpm_wraddress_control === "REGISTERED")) && ((wrclock === 1'bz) || (wrclken == 1'bz)))
		begin
			$display("Error! wrclock = 1'bz. wrclock and wrclken pins must be used.\n");
		end

		// check if lpm_rdaddress_control is set to registered
		// rdclock and rdclken must be used.
		if ((lpm_rdaddress_control === "REGISTERED") && ((rdclock === 1'bz) || (rdclken == 1'bz)))
		begin
			$display("Error! rdclock = 1'bz. rdclock and rdclken pins must be used.\n");
		end

		// check if lpm_outdata, rdclock must be used
		if ((lpm_outdata === "REGISTERED") && (rdclock === 1'bz))
		begin
			$display("Error! lpm_outdata = REGISTERED, rdclock = 1'bz . rdclock pnd rdclken pins must be used.\n");
		end

		for (i=0; i < lpm_width; i=i+1)
		begin
			ZEROS[i] = 1'b0;
			UNKNOWN[i] = 1'bX;
		end 
				
		for (i = 0; i < lpm_numwords; i=i+1)
			mem_data[i] = ZEROS;

		// load data to the RAM
		if (lpm_file != "UNUSED")
		begin
			$convert_hex2ver(lpm_file, lpm_width, ram_initf);
			$readmemh(ram_initf, mem_data);
		end
	end

		
	always @(posedge i_wrclock)
	begin
		if (i_wrclken)
		begin
			if ((lpm_indata === "REGISTERED") && (lpm_wraddress_control === "REGISTERED"))
			begin
				new_wraddress <= wraddress;
				new_data <= data;
				wren_event <= wren;
			end
			else
			begin
				if ((lpm_indata === "REGISTERED") && (lpm_wraddress_control === "UNREGISTERED"))
					new_data <= data;

				if ((lpm_indata === "UNREGISTERED") && (lpm_wraddress_control === "REGISTERED"))
				begin
					new_wraddress <= wraddress;
					wren_event <= wren;
				end
			end
		end
	end


	always @(data)
	begin
		if (lpm_indata === "UNREGISTERED")
			new_data <= data;
	end
	
	always @(wraddress)
	begin
		if (lpm_wraddress_control === "UNREGISTERED")
			new_wraddress <= wraddress;
	end

	always @(rdaddress)
	begin
		if (lpm_rdaddress_control === "UNREGISTERED")
			new_raddress <= rdaddress;
	end
	
	always @(wren)
	begin
		if (lpm_wraddress_control === "UNREGISTERED")
			wren_event <= wren;
	end

	always @(i_rden)
	begin
		if (lpm_rdaddress_control === "UNREGISTERED")
			rden_event <= i_rden;
	end
	
	always @(new_data or new_wraddress or wren_event)
	begin 
		if (ValidAddress(new_wraddress))
		begin
			if ((wren_event) && (i_wrclken))
				mem_data[new_wraddress] <= new_data;
		end
		else
		begin
			if (lpm_outdata === "UNREGISTERED")
				tmp_q <= UNKNOWN;
		end
	end

	always @(posedge i_rdclock)
	begin
		if (lpm_rdaddress_control == "REGISTERED")
			if (i_rdclken)
			begin
				new_raddress <= rdaddress;
				rden_event <= i_rden;
			end
		if (lpm_outdata === "REGISTERED")
		begin
			if ((i_rdclken) && (rden_event))
			begin
				if (ValidAddress(new_raddress))
				begin
					tmp_q <= mem_data[new_raddress];
				end
				else
					tmp_q <= UNKNOWN;
			end
		end
	end
 
	//assign q = ( lpm_outdata === "UNREGISTERED" ) ? mem_data[new_raddress] : tmp_q;

	always @(mem_data[new_raddress] or tmp_q or i_rden)
	begin
		if (i_rden || lpm_outdata === "REGISTERED")
			prev_q <= ( lpm_outdata === "UNREGISTERED" ) ? mem_data[new_raddress] : tmp_q;
	end

	assign q = prev_q;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_ram_dp") || (lpm_type !== "lpm_ram_dp"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_ram_dp

//------------------------------------------------------------------------

module lpm_ram_io ( dio, inclock, outclock, we, memenab, outenab, address );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_widthad = 1;
	parameter lpm_numwords = 1<< lpm_widthad;
	parameter lpm_indata = "REGISTERED";
	parameter lpm_address_control = "REGISTERED";
	parameter lpm_outdata = "REGISTERED";
	parameter lpm_file = "UNUSED";
	parameter lpm_type = "lpm_ram_io";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_widthad-1:0] address;
	input  inclock, outclock, we;
	input  memenab;
	input  outenab;
	inout  [lpm_width-1:0] dio;


	// inernal reg 
	reg  [lpm_width-1:0] mem_data [lpm_numwords-1:0];
	reg  [lpm_width-1:0] tmp_io;
	reg  [lpm_width-1:0] tmp_q;
	reg  [lpm_width-1:0] pdio;
	reg  [lpm_widthad-1:0] paddress;
	reg  pwe;
	reg  [lpm_width-1:0] ZEROS, UNKNOWN, HiZ;
	reg  [8*256:1] ram_initf;
	integer i;

	tri0 inclock;
	tri0 outclock;
	  
	buf (i_inclock, inclock);
	buf (i_outclock, outclock);


//---------------------------------------------------------------//
	function ValidAddress;
		input [lpm_widthad-1:0] paddress;
		
		begin
			ValidAddress = 1'b0;
			if (^paddress ==='bx)
				$display("%d:Error: Invalid address.", $time);
			else if (paddress >= lpm_numwords)
				$display("%d:Error: Address out of bound on RAM.", $time);
			else
				ValidAddress = 1'b1;
		end
	endfunction
//---------------------------------------------------------------//
		
	initial
	begin

		if (lpm_width <= 0)
			$display("Error! lpm_width parameter must be greater than 0.");

		if (lpm_widthad <= 0)
			$display("Error! lpm_widthad parameter must be greater than 0.");

		// check for number of words out of bound
		if ((lpm_numwords > (1 << lpm_widthad))
			||(lpm_numwords <= (1 << (lpm_widthad-1))))
		begin
			$display("Error! lpm_numwords must equal to the ceiling of log2(lpm_widthad).");
		end

		if ((lpm_indata !== "REGISTERED") && (lpm_indata !== "UNREGISTERED")) 
		begin
			$display("Error! lpm_indata must be REGISTERED (the default) or UNREGISTERED.");
		end
			
		if ((lpm_address_control !== "REGISTERED") && (lpm_address_control !== "UNREGISTERED")) 
		begin
			$display("Error! lpm_address_control must be REGISTERED (the default) or UNREGISTERED.");
		end
			
		if ((lpm_outdata !== "REGISTERED") && (lpm_outdata !== "UNREGISTERED")) 
		begin
			$display("Error! lpm_outdata must be REGISTERED (the default) or UNREGISTERED.");
		end
			

		// check if lpm_indata or lpm_address_control is set to registered
		// inclock must be used.
		if (((lpm_indata === "REGISTERED") || (lpm_address_control === "REGISTERED")) && (inclock === 1'bz))
		begin
			$display("Error! inclock = 1'bz.  Inclock pin must be used.\n");
		end
		 
		// check if lpm_outdata, outclock must be used
		if ((lpm_outdata === "REGISTERED") && (outclock === 1'bz))
		begin
			$display("Error! lpm_outdata is REGISTERED, outclock = 1'bz.  Outclock pin must be used.\n");  
		end
		 
		for (i=0; i < lpm_width; i=i+1)
		begin
			ZEROS[i] = 1'b0;
			UNKNOWN[i] = 1'bX;
			HiZ[i] = 1'bZ;
		end 
			
		for (i = 0; i < lpm_numwords; i=i+1)
			mem_data[i] = ZEROS;

		// Initialize input/output 
		pdio = 0;
		paddress = 0;
		tmp_io = 0;
		tmp_q = 0;

		// load data to the RAM
		if (lpm_file != "UNUSED")
		begin
			$convert_hex2ver(lpm_file, lpm_width, ram_initf);
			$readmemh(ram_initf, mem_data);
		end
	end


	always @(dio)
	begin
		if (lpm_indata === "UNREGISTERED")
			pdio <=  dio;
	end
		
	always @(address)
	begin
		if (lpm_address_control === "UNREGISTERED")
			paddress <=  address;
	end
		
		
	always @(we)
	begin
		if (lpm_address_control === "UNREGISTERED")
			pwe <=  we;
	end
	
	always @(posedge i_inclock)
	begin
		if (lpm_indata === "REGISTERED")
			pdio <=  dio;

		if (lpm_address_control === "REGISTERED")
		begin
			paddress <=  address;
			pwe <=  we;
		end
	end

	always @(pdio or paddress or pwe or memenab)
	begin :block_a
		if (ValidAddress(paddress))
		begin
			if ((lpm_indata === "UNREGISTERED" && lpm_address_control === "UNREGISTERED") || (lpm_address_control === "UNREGISTERED"))
			begin
				if (pwe && memenab)
				mem_data[paddress] <= pdio;
			end

			if (lpm_outdata === "UNREGISTERED")
			begin
				tmp_q <= mem_data[paddress];
				tmp_q <= mem_data[paddress];
			end
		end
		else
		begin
			if (lpm_outdata === "UNREGISTERED")
				tmp_q <= UNKNOWN;
		end
	end

	always @(negedge i_inclock)
	begin
		if (lpm_address_control === "REGISTERED")
		begin
			if (pwe && memenab)
			mem_data[paddress] <= pdio;
		end
	end

	always @(posedge i_outclock)
	begin
		if (lpm_outdata === "REGISTERED")
		begin
			tmp_q <= mem_data[paddress];
		end
	end

	always @(memenab or outenab or tmp_q)
	begin
		if (memenab && outenab)
			tmp_io <= tmp_q;
		else if (!memenab || (memenab && !outenab))
			tmp_io <= HiZ;
	end
 
	assign dio =  tmp_io;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_ram_io") || (lpm_type !== "lpm_ram_io"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_ram_io
 
//------------------------------------------------------------------------

module lpm_rom ( q, inclock, outclock, memenab, address );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_widthad = 1;
	parameter lpm_numwords = 1<< lpm_widthad;
	parameter lpm_address_control = "REGISTERED";
	parameter lpm_outdata = "REGISTERED";
	parameter lpm_file = "rom.hex";
	parameter lpm_type = "lpm_rom";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input  [lpm_widthad-1:0] address;
	input  inclock, outclock;
	input  memenab;
	output [lpm_width-1:0] q;

	// inernal reg 
	reg  [lpm_width-1:0] mem_data [lpm_numwords-1:0];
	reg  [lpm_widthad-1:0] paddress;
	reg  [lpm_width-1:0] tmp_q;
	reg  [lpm_width-1:0] tmp_q_reg;
	reg  [lpm_width-1:0] ZEROS, UNKNOWN, HiZ;
	reg  [8*256:1] rom_initf;
	integer i;

	tri0 inclock;
	tri0 outclock;
	tri1 memenab;

	buf (i_inclock, inclock);
	buf (i_outclock, outclock);
	buf (i_memenab, memenab);


//---------------------------------------------------------------//
	function ValidAddress;
		input [lpm_widthad-1:0] address;
		begin
			ValidAddress = 1'b0;
			if (^address =='bx)
				$display("%d:Error: Invalid address.", $time);
			else if (address >= lpm_numwords)
				$display("%d:Error: Address out of bound on ROM.", $time);
			else
				ValidAddress = 1'b1;
		end
	endfunction
//---------------------------------------------------------------//
		
	initial     
	begin
		// Initialize output
		tmp_q = 0;
		tmp_q_reg = 0;
		paddress = 0;
 
		if (lpm_file === "")
			$display("Error! rom module must have data file for initialization\n.");
 
		if (lpm_width <= 0)
			$display("Error! lpm_width parameter must be greater than 0.");
	 
		if (lpm_widthad <= 0)
			$display("Error! lpm_widthad parameter must be greater than 0.");
		 
		 
		// check for number of words out of bound
		if ((lpm_numwords > (1 << lpm_widthad))
			||(lpm_numwords <= (1 << (lpm_widthad-1))))
		begin
			$display("Error! lpm_numwords must equal to the ceiling of log2(lpm_widthad).");
		end   

		if ((lpm_address_control !== "REGISTERED") && (lpm_address_control !== "UNREGISTERED"))
		begin
			$display("Error! lpm_address_control must be REGISTERED (the default) or UNREGISTERED.");
		end

		if ((lpm_outdata !== "REGISTERED") && (lpm_outdata !== "UNREGISTERED"))
		begin
			$display("Error! lpm_outdata must be REGISTERED (the default) or UNREGISTERED.");
		end

		// check if lpm_address_control is set to registered
		// inclock must be used.
		if ((lpm_address_control === "REGISTERED") && (inclock === 1'bz))
		begin
			$display("Error! inclock = 1'bz.  Inclock pin must be used.\n");
		end  

		// check if lpm_outdata, outclock must be used
		if ((lpm_outdata === "REGISTERED") && (outclock === 1'bz))
		begin
			$display("Error! lpm_outdata is REGISTERED, outclock = 1'bz.  Outclock must be used.\n");
		end
		 
		for (i=0; i < lpm_width; i=i+1)
		begin
			ZEROS[i] = 1'b0;
			UNKNOWN[i] = 1'bX;
			HiZ[i] = 1'bZ;
		end 
			
		for (i = 0; i < lpm_numwords; i=i+1)
			mem_data[i] = ZEROS;

		// load data to the ROM
		if (lpm_file != "")
		begin
			$convert_hex2ver(lpm_file, lpm_width, rom_initf);
			$readmemh(rom_initf, mem_data);
		end
	end

	always @(posedge i_inclock)
	begin
		if (lpm_address_control === "REGISTERED")
			paddress <=  address;
	end
 
	always @(address)
	begin
		if (lpm_address_control === "UNREGISTERED")
				paddress <=  address;
	end

				   
	always @(paddress)
	begin 
		if (ValidAddress(paddress))
		begin
			if (lpm_outdata === "UNREGISTERED")
				tmp_q_reg <=  mem_data[paddress];
		end
		else
		begin
			if (lpm_outdata === "UNREGISTERED")
				tmp_q_reg <= UNKNOWN;
		end
	end

	always @(posedge i_outclock)
	begin
		if (lpm_outdata === "REGISTERED")
		begin
			if (ValidAddress(paddress))
				tmp_q_reg <=  mem_data[paddress];
			else
				tmp_q_reg <= UNKNOWN;
		end
	end
 
	
	always @(i_memenab or tmp_q_reg)
	begin
		if (i_memenab)
			tmp_q <= tmp_q_reg;
		else if (!i_memenab)
			tmp_q <= HiZ;
	end
	 
	assign q = tmp_q;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_rom") || (lpm_type !== "lpm_rom"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_rom
 
//------------------------------------------------------------------------

module lpm_fifo (data, clock, wrreq, rdreq, aclr, sclr, q, usedw, full, empty);

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width  = 1;
	parameter lpm_widthu  = 1;
	parameter lpm_numwords = 2;
	parameter lpm_showahead = "OFF";
	parameter lpm_type = "lpm_fifo";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6";

	input [lpm_width-1:0] data;
	input clock;
	input wrreq;
	input rdreq;
	input aclr;
	input sclr;
	output [lpm_width-1:0] q;
	output [lpm_widthu-1:0] usedw;
	output full;
	output empty;


	// internal reg
	reg [lpm_width-1:0] mem_data [lpm_numwords-1:0];
	reg [lpm_width-1:0] tmp_q;
	reg [lpm_width-1:0] ZEROS;
	reg [lpm_widthu+1:0] count_id;
	reg [lpm_widthu-1:0] write_id;
	reg [lpm_widthu-1:0] read_id;
	reg empty_flag;
	reg full_flag;
	integer i;

	tri0 aclr;
	tri0 sclr;

	buf (i_aclr, aclr);
	buf (i_sclr, sclr);

	initial
	begin
  
		if (lpm_width <= 0)
			$display("Error! lpm_width must be greater than 0.");

		if (lpm_numwords <= 1)
			$display("Error! lpm_numwords must be greater than or equal to 2.");

		// check for number of words out of bound
		if ((lpm_widthu !=1) && (lpm_numwords > (1 << lpm_widthu)))
			$display("Error! lpm_numwords MUST equal to the ceiling of log2(lpm_widthu).");

		if (lpm_numwords <= (1 << (lpm_widthu-1)))
		begin
			$display("Error! lpm_widthu is too big for the specified lpm_numwords.");
		end

		for (i=0; i < lpm_width; i=i+1)
			ZEROS[i] = 1'b0;

		for (i = 0; i < lpm_numwords; i=i+1)
			mem_data[i] = ZEROS;

		full_flag = 0;
		empty_flag = 1;
		read_id = 0;
		write_id = 0;
		count_id = 0;
		tmp_q = ZEROS;
	end

	always @(posedge clock or i_aclr)
	begin
		if (i_aclr)
		begin
			tmp_q = ZEROS;
			full_flag = 0;
			empty_flag = 1;
			read_id = 0;
			write_id = 0;
			count_id = 0;
			if (lpm_showahead == "ON")
				tmp_q = mem_data[0];
		end
		else if (clock)
		begin
			if (i_sclr)
			begin
				tmp_q = mem_data[read_id];
				full_flag = 0;
				empty_flag = 1;
				read_id = 0;
				write_id = 0;
				count_id = 0;
				if (lpm_showahead == "ON")
					tmp_q = mem_data[0];
			end
			else
			begin
				// both WRITE and READ
				if ((wrreq && !full_flag) && (rdreq && !empty_flag))
				begin
					mem_data[write_id] = data;
					if (write_id >= lpm_numwords-1)
						write_id = 0;
					else
						write_id = write_id + 1;

					tmp_q = mem_data[read_id];
					if (read_id >= lpm_numwords-1)
						read_id = 0;
					else
						read_id = read_id + 1;
					if (lpm_showahead == "ON")
						tmp_q = mem_data[read_id];
				end

				// WRITE
				else if (wrreq && !full_flag)
				begin
					mem_data[write_id] = data;
					if (lpm_showahead == "ON")
						tmp_q = mem_data[read_id];
					count_id = count_id + 1;
					empty_flag = 0;
					if (count_id >= lpm_numwords)
					begin
						full_flag = 1;
						count_id = lpm_numwords;
					end
					if (write_id >= lpm_numwords-1)
						write_id = 0;
					else
						write_id = write_id + 1;
				end
							
				// READ
				else if (rdreq && !empty_flag)
				begin
					tmp_q = mem_data[read_id];
					count_id = count_id - 1;
					full_flag = 0;
					if (count_id <= 0)
					begin
						empty_flag = 1;
						count_id = 0;
					end
					if (read_id >= lpm_numwords-1)
						read_id = 0;
					else
						read_id = read_id + 1;
					if (lpm_showahead == "ON")
						tmp_q = mem_data[read_id];
				end
			end
		end
	end

	assign q = tmp_q;
	assign full = full_flag;
	assign empty = empty_flag;
	assign usedw = count_id;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_fifo") || (lpm_type !== "lpm_fifo"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_fifo

//------------------------------------------------------------------------

module lpm_fifo_dc ( data, rdclock, wrclock, aclr, rdreq, wrreq, rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q );

// NOTE: Parameters must be declared in the same order as the Properties
//       are specified in the Cell Specification document.
	parameter lpm_width = 1;
	parameter lpm_widthu = 1;
	parameter lpm_numwords = 2;
	parameter lpm_showahead = "OFF";
	parameter lpm_type = "lpm_fifo_dc";
	parameter lpm_hint = "UNUSED";
	parameter lpm_source_version = "lpm 220 version 1.6"; 

	input [lpm_width-1:0] data;
	input rdclock;
	input wrclock;
	input wrreq;
	input rdreq;
	input aclr;
	output rdfull;
	output wrfull;
	output rdempty;
	output wrempty;
	output [lpm_width-1:0] q;
	output [lpm_widthu-1:0] rdusedw;
	output [lpm_widthu-1:0] wrusedw;
	  

	// internal reg
	reg [lpm_width-1:0] mem_data [lpm_numwords-1:0];
	integer pipe_wrptr [0:5];       // [0:RDPTR_DP];
	integer pipe_rdptr [0:5];       // [0:WRPTR_DP];
	integer pipe_rdusedw [0:1];     // [0:RDUSEDW_DP];
	integer pipe_wrusedw [0:1];     // [0:WRUSEDW_DP];

	reg [lpm_width-1:0] i_q;
	reg i_rdempty;
	reg i_wrempty;
	reg i_rdfull;
	reg i_wrfull;
	reg x_rdempty;
	reg x_wrfull;
	integer i_rdptr;
	integer i_wrptr;
	integer i_rdusedw;
	integer i_wrusedw;
	integer x_rdptr;
	integer x_wrptr;

	reg [lpm_width-1:0] ZEROS;
	integer RDPTR_DP;
	integer WRPTR_DP;
	integer RDUSEDW_DP;
	integer WRUSEDW_DP;
	integer FULL_RISEEARLY;
	integer i;

	tri0 aclr;
	buf (i_aclr, aclr);


	initial
	begin
  
		if (lpm_width <= 0)
			$display("Error! lpm_width must be greater than 0.");

		if (lpm_numwords <= 1)
			$display("Error! lpm_numwords must be greater than or equal to 2.");

		// check for number of words out of bound
		if ((lpm_widthu !=1) && (lpm_numwords > (1 << lpm_widthu)))
			$display("Error! lpm_numwords MUST equal to the ceiling of log2(lpm_widthu).");

		if (lpm_numwords <= (1 << (lpm_widthu-1)))
			$display("Error! lpm_widthu is too big for the specified lpm_numwords.");
			
		for (i=0; i<lpm_width; i=i+1)
			ZEROS[i] = 1'b0;

		// MEMORY INITIALIZATION
		for (i=0; i<lpm_numwords; i=i+1)
			mem_data[i] = ZEROS;

		// INITERNAL VARIABLES INIT
		i_q = ZEROS;
		i_rdptr = 0;
		i_wrptr = 0;
		i_rdempty = 1;
		i_wrempty = 1;
		i_rdfull = 0;
		i_wrfull = 0;
		i_rdusedw = 0;
		i_wrusedw = 0;

		// CONSTANTS
		RDPTR_DP = 5;
		WRPTR_DP = 5;
		RDUSEDW_DP = 1;
		WRUSEDW_DP = 1;
		FULL_RISEEARLY = 2;

		// CLEAR PIPELINES
		for (i=0; i<RDPTR_DP; i=i+1)
			pipe_wrptr[i] = 0;
		for (i=0; i<WRPTR_DP; i=i+1)
			pipe_rdptr[i] = 0;
		for (i=0; i<RDUSEDW_DP; i=i+1)
			pipe_rdusedw[i] = 0;
		for (i=0; i<WRUSEDW_DP; i=i+1)
			pipe_wrusedw[i] = 0;

	end

	always @(i_aclr)
	begin
		if (i_aclr)
		begin
			i_q = ZEROS;
			i_rdptr = 0;
			i_wrptr = 0;
			i_rdempty = 1;
			i_wrempty = 1;
			i_rdfull = 0;
			i_wrfull = 0;
			if (lpm_showahead == "ON")
				i_q = mem_data[0];
			
			// CLEAR PIPELINES
			for (i=0; i<RDPTR_DP; i=i+1)
				pipe_wrptr[i] = 0;
			for (i=0; i<WRPTR_DP; i=i+1)
				pipe_rdptr[i] = 0;
			for (i=0; i<RDUSEDW_DP; i=i+1)
				pipe_rdusedw[i] = 0;
			for (i=0; i<WRUSEDW_DP; i=i+1)
				pipe_wrusedw[i] = 0;
		end
	end

	always @(posedge wrclock)
	begin
		if (!i_aclr)
		begin
			// SET FLAGS
			x_wrfull = i_wrfull;
			if (i_wrusedw >= lpm_numwords-1-FULL_RISEEARLY)
				i_wrfull = 1;
			else
				i_wrfull = 0;
			
			if ((i_wrusedw <= 0) && (i_rdptr == i_wrptr))
				i_wrempty = 1;

			x_wrptr = i_wrptr;
			if (wrreq && !x_wrfull)  // && ! wrreq'event
			begin
				// WRITE DATA
				mem_data[i_wrptr] = data;

				// SET FLAGS
				i_wrempty = 0;

				// INC WRPTR
				if (i_wrptr >= lpm_numwords-1)
					i_wrptr = 0;
				else
					i_wrptr = i_wrptr + 1;
			end

			// DELAY RDPTR FOR WRUSEDW
			pipe_rdptr[WRPTR_DP] = i_rdptr;
			for (i=0; i<WRPTR_DP; i=i+1)
				pipe_rdptr[i] = pipe_rdptr[i+1];
			if (x_wrptr >= pipe_rdptr[0])
				pipe_wrusedw[WRUSEDW_DP] = x_wrptr - pipe_rdptr[0];
			else
				pipe_wrusedw[WRUSEDW_DP] = lpm_numwords + x_wrptr - pipe_rdptr[0];

			// DELAY WRUSEDW
			for (i=0; i<WRUSEDW_DP; i=i+1)
				pipe_wrusedw[i] = pipe_wrusedw[i+1];
			i_wrusedw = pipe_wrusedw[0];
		end
	end

	always @(posedge rdclock)
	begin    
		if (!i_aclr)
		begin
			// SET FLAGS
			x_rdempty = i_rdempty;
			if (i_rdusedw >= lpm_numwords-1-FULL_RISEEARLY)
				i_rdfull = 1;
			else
				i_rdfull = 0;

			if (i_rdptr == i_wrptr)
				i_rdempty = 1;
			else if (i_rdempty && (i_rdusedw > 0))
				i_rdempty = 0;

			// Q SHOWAHEAD
			if (lpm_showahead == "ON" && i_rdptr != i_wrptr)
				i_q = mem_data[i_rdptr];

			x_rdptr = i_rdptr;
			if (rdreq && !x_rdempty)  // && ! rdreq'event
			begin
				// READ DATA
				i_q = mem_data[i_rdptr];
				if (lpm_showahead == "ON")
				begin
					if (i_rdptr == i_wrptr)
						i_q = ZEROS;
					else
					begin
						if (i_rdptr >= lpm_numwords-1)
							i_q = mem_data[0];
						else
							i_q = mem_data[i_rdptr+1];
					end
				end

				// SET FLAGS
				if ((i_rdptr == lpm_numwords-1 && i_wrptr == 0) ||
					(i_rdptr+1 == i_wrptr))
					i_rdempty = 1;

				// INC RDPTR
				if (i_rdptr >= lpm_numwords-1)
					i_rdptr = 0;
				else
					i_rdptr = i_rdptr + 1;
			
			end
			// DELAY WRPTR FOR RDUSEDW
			pipe_wrptr[RDPTR_DP] = i_wrptr;
			for (i=0; i<RDPTR_DP; i=i+1)
				pipe_wrptr[i] = pipe_wrptr[i+1];
			if (pipe_wrptr[0] >= x_rdptr)
				pipe_rdusedw[RDUSEDW_DP] = pipe_wrptr[0] - x_rdptr;
			else
				pipe_rdusedw[RDUSEDW_DP] = lpm_numwords + pipe_wrptr[0] - x_rdptr;

			// DELAY RDUSEDW
			for (i=0; i<RDUSEDW_DP; i=i+1)
				pipe_rdusedw[i] = pipe_rdusedw[i+1];
			i_rdusedw = pipe_rdusedw[0];
		end
	end
			 
	assign q = i_q;
	assign wrfull = i_wrfull;
	assign wrempty = i_wrempty;
	assign rdfull = i_rdfull;
	assign rdempty = i_rdempty;
	assign wrusedw = i_wrusedw;
	assign rdusedw = i_rdusedw;

// Check for previous Parameter declaration order
initial if ((lpm_width === "lpm_fifo_dc") || (lpm_type !== "lpm_fifo_dc"))
  begin
    $display ("LPM 220 Version 1.6 Parameter Order changed; update instantiation");
    $finish;
  end
endmodule // lpm_fifo_dc
