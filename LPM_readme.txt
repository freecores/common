// These LPM files were retrieved from
//    http://www.edif.org/lpmweb/
//
// They are based on the Library of Parameterized Modules, which is
//   advocated for and supported by Altera.
//
// These files are based on the Version 1.5 LPM source.  The documentation
//   corresponding to this source is titled "LPM 2 2 0" in the documentation.
//
// The files of interest are:
//   220_cells_specification.pdf:  The specifications for each module.
//   220_edif-1_usage.pdf:         EDIF instantiation notes.
//   220_verilog_usage.pdf:        Verilog instantiation notes.
//   220_vhdl_usage.pdf:           VHDL instantiation notes.
//   220_vhdl_declarations.vhd:    VHDL source which might be module declarations.
//   220_vhdl_models.vhd:          VHDL source for the LPM library version "2 2 0".
//   220_verilog_models.v:         Original Verilog sources for LPM library "2 2 0".
//   220_count4_example.vhd:       Example of a counter instantiation in VHDL.
//   220_count4_example.v:         Example of a counter instantiation in verilog.
//   220_convert_hex2ver_pli.c:    PLI cource to initialize storage elements in verilog.
//
// The 220_verilog_models.v file is broken into parts to make it easier to use.
// Example module instantiations for the verilog modules are included in
//   these modules.
//
//   LPM_gates.v:                  Simple gates in verilog.
//   LPM_arithmetic.v:             Arithmetic elements in verilog.
//   LPM_storage.v:                Storage elements in verilog.
//   LPM_pads.v:                   IO pads in verilog.

