`ifndef INCLUDED_test_default_offset
`define INCLUDED_test_default_offset

import srm_pkg::*;

class test_default_offset extends srm_unit_test;

  cpu_reg32 regmodel;

  function new();
    super.new("test_default_offset");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
  endfunction

  task test_default_root_offset();
    `TEST_VALUE('h0, regmodel.get_offset("cpu_map"), "Default offset of root is 0");
  endtask

  virtual task run();
    `RUN_TEST(test_default_root_offset);
  endtask

endclass
`endif
