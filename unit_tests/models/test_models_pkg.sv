// Package with all the memory models.
`ifndef TEST_MODELS_PKG_SV
`define TEST_MODELS_PKG_SV

package test_models_pkg; 
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import srm_pkg::*;

  `include "cpu_reg32.svh"
  `include "cpu_table32.svh"
  `include "cpu_multi_field.svh"
  `include "cpu_volatile_field.svh"
  `include "cpu_top.svh"
endpackage

`endif
