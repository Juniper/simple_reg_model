`ifndef INCLUDED_unit_tests_svh
`define INCLUDED_unit_tests_svh

package unit_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import srm_pkg::*;
  import test_models_pkg::*;

  import srm_unit_test_pkg::*;
  `include "utils.svh"
  `include "test_reg32.svh"
  `include "test_reg32_rand.svh"
  `include "test_table32.svh"
  `include "test_top.svh"
  `include "test_default_offset.svh"
  `include "test_field_access.svh"
  `include "test_reg_reset.svh"
  `include "test_table_reset.svh"
  `include "test_reg_rw.svh"
  `include "test_table_rw.svh"
  `include "test_field_rw.svh"
  `include "test_field_policies.svh"
  `include "test_leaf_policies.svh"
  `include "test_srm_utils_1.svh"
  `include "test_srm_utils_2.svh"
  `include "test_volatile_field.svh"
  `include "test_bus_predictor.svh"
  `include "test_reg_coverage.svh"
  `include "test_model_coverage.svh"
  `include "test_table_coverage.svh"
endpackage

`endif
