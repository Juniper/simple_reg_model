`ifndef INCLUDED_test_reg32_sv
`define INCLUDED_test_reg32_sv

import srm_pkg::*;
class test_reg32 extends srm_unit_test;

  cpu_reg32 regmodel;

  cpu_reg32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_reg32");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset(.addr_map_name("cpu_map"), .offset(64'h10000));

  endfunction

  task test_set_get_r1;
    wr_data.field = 32'hdeadbeef;
    regmodel.r1.set(wr_data);
    rd_data = regmodel.r1.get();
    `TEST_VALUE(32'hdeadbeef, rd_data.field, "get data matches the set data"); 
  endtask

  task test_tree;
    srm_component leaves[$];
    regmodel.get_leaf_nodes(leaves);
    `TEST_VALUE(1, regmodel.is_root_node(), "Root node match"); 
    `TEST_VALUE(4, regmodel.num_children(), "Root node has 4 children");
    `TEST_VALUE(5, leaves.size(), "r1 to r5 children");
    `TEST_STRING("regmodel.r1", leaves[0].get_full_name(), "Full name r1 must match");
    `TEST_STRING("regmodel.r2", leaves[1].get_full_name(), "Full name r2 must match");
    `TEST_STRING("regmodel.r3", leaves[2].get_full_name(), "Full name r3 must match");
    `TEST_STRING("regmodel.blk4.r4", leaves[3].get_full_name(), "Full name r4 must match");
    `TEST_STRING("regmodel.blk4.r5", leaves[4].get_full_name(), "Full name r5 must match");
  endtask

  task test_address_map;
    `TEST_VALUE(32'h10000, regmodel.get_offset("cpu_map"), "Base addr of cpu must match");
    `TEST_VALUE(32'h10100, regmodel.r1.get_offset("cpu_map"), "Start addr of r1 must match");
    `TEST_VALUE(32'h10200, regmodel.r2.get_offset("cpu_map"), "Start addr of r2 must match");
    `TEST_VALUE(32'h10300, regmodel.r3.get_offset("cpu_map"), "Start addr of r3 must match");
    `TEST_VALUE(32'h10400, regmodel.blk4.get_offset("cpu_map"), "Start addr of blk4 must match");
    `TEST_VALUE(32'h10410, regmodel.blk4.r4.get_offset("cpu_map"), "Start addr of r4 must match");
    `TEST_VALUE(32'h10420, regmodel.blk4.r5.get_offset("cpu_map"), "Start addr of r5 must match");
  endtask

  virtual task run();
    `RUN_TEST(test_set_get_r1);
    `RUN_TEST(test_tree);
    `RUN_TEST(test_address_map);
  endtask

endclass
`endif
