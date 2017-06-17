`ifndef INCLUDED_test_table_reset
`define INCLUDED_test_table_reset

import srm_pkg::*;

class test_table_reset extends srm_unit_test;

  cpu_multi_field regmodel;

  function new();
    super.new("test_table_reset");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
  endfunction

  task test_get_reset_value();
    `TEST_VALUE(1, regmodel.r2.is_resettable("HARD"), "Table must be resettable");
  endtask

  virtual task run();
    `RUN_TEST(test_get_reset_value);
  endtask

endclass
`endif
