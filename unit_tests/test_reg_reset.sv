`ifndef INCLUDED_test_reset
`define INCLUDED_test_reset

import srm_pkg::*;

class test_reg_reset extends srm_unit_test;

  cpu_multi_field regmodel;

  function new();
    super.new("test_reg_reset");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
  endfunction

  task test_get_reset_value();
    `TEST_VALUE(1, regmodel.r1.f0.is_resettable(), "Field f0 must be resettable");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "read out hard value");
  endtask

  task test_bist_reset();
  endtask

  virtual task run();
    `RUN_TEST(test_get_reset_value);
  endtask

endclass
`endif
