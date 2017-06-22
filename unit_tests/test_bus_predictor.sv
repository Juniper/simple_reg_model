`ifndef INCLUDED_test_bus_predictor_svh
`define INCLUDED_test_bus_predictor_svh

import srm_pkg::*;

class test_bus_predictor extends srm_unit_test;
  cpu_reg32 regmodel;

  function new();
    super.new("test_bus_predictor");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset(.addr_map_name("cpu_map"), .offset('h10000));
  endfunction

  task test_address_r1;
    srm_component r1 = regmodel.address_2_instance(64'h10100);
    `TEST_VALUE(r1, regmodel.r1, "Handle must be the same");
  endtask

  virtual task run();
    `RUN_TEST(test_address_r1);
  endtask

endclass

`endif
