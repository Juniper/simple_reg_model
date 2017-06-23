`ifndef INCLUDED_test_bus_predictor_svh
`define INCLUDED_test_bus_predictor_svh

import srm_pkg::*;

class test_bus_predictor extends srm_unit_test;
  cpu_reg32 reg32_model;
  cpu_table32 table32_model;

  function new();
    super.new("test_bus_predictor");
  endfunction

  virtual function void setup();
    reg32_model = new(.name("reg32_model"), .parent(null));
    reg32_model.set_offset(.addr_map_name("cpu_map"), .offset('h10000));
    
    table32_model = new(.name("table32_model"), .parent(null));
    table32_model.set_offset(.addr_map_name("cpu_map"), .offset('h20000));
  endfunction

  task test_size_reg;
    `TEST_VALUE(4, reg32_model.r1.get_size("cpu_map"), "r1 is 32b wide");
    `TEST_VALUE(4, reg32_model.blk4.r4.get_size("cpu_map"), "r4 is 32b wide");
    `TEST_VALUE('h24, reg32_model.blk4.get_size("cpu_map"), "blk4 has 2 registers spaced out");
  endtask

  task test_size_table;
    `TEST_VALUE(40, table32_model.r1.get_size("cpu_map"), "table r1 has 10 entries of 4B");
    `TEST_VALUE(40, table32_model.r2.get_size("cpu_map"), "table r2 has 10 entries of 4B");
    `TEST_VALUE(40, table32_model.r3.get_size("cpu_map"), "table r3 has 10 entries of 4B");
    `TEST_VALUE('h40 + 10*4, table32_model.blk4.get_size("cpu_map"), "table blk4 size match");
  endtask

  task test_address_reg;
    srm_component r = reg32_model.address_2_instance("cpu_map", 64'h10100);
    `TEST_VALUE(reg32_model.r1, r, "Handle r1 must be the same");
    r = reg32_model.address_2_instance("cpu_map", 64'h10200);
    `TEST_VALUE(reg32_model.r2, r,  "Handle r2 must be the same");
    r = reg32_model.address_2_instance("cpu_map", 64'h10300);
    `TEST_VALUE(reg32_model.r3, r,  "Handle r3 must be the same");
    r = reg32_model.address_2_instance("cpu_map", 64'h10410);
    `TEST_VALUE(reg32_model.blk4.r4, r, "Handle r4 must be the same");
    r = reg32_model.address_2_instance("cpu_map", 64'h10420);
    `TEST_VALUE(reg32_model.blk4.r5, r, "Handle r5 must be the same");
  endtask

  virtual task run();
    `RUN_TEST(test_size_reg);
    `RUN_TEST(test_size_table); 
    `RUN_TEST(test_address_reg);
  endtask

endclass

`endif
