`ifndef INCLUDED_test_top_sv
`define INCLUDED_test_top_sv


class test_top extends srm_unit_test;

  cpu_top regmodel;

  function new();
    super.new("test_top");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset("cpu_map", 64'hA0000);
  endfunction

  task test_tree;
    srm_node leaves[$];
    regmodel.get_leaf_nodes(leaves);
    `TEST_VALUE(1, regmodel.is_root_node(), "Root node match"); 
    `TEST_VALUE(2, regmodel.num_children(), "Root node has 2 children");
    `TEST_VALUE(10, leaves.size(), "r1 to r5 children on register and table.");

    `TEST_STRING("regmodel.cpu_reg32.r1", leaves[0].get_full_name(), "name r1 must match");
    `TEST_STRING("regmodel.cpu_reg32.r2", leaves[1].get_full_name(), "name r2 must match");
    `TEST_STRING("regmodel.cpu_reg32.r3", leaves[2].get_full_name(), "name r3 must match");
    `TEST_STRING("regmodel.cpu_reg32.blk4.r4", leaves[3].get_full_name(), "name r4 must match");
    `TEST_STRING("regmodel.cpu_reg32.blk4.r5", leaves[4].get_full_name(), "name r5 must match");
    
    `TEST_STRING("regmodel.cpu_table32.r1", leaves[5].get_full_name(), "name r1 must match");
    `TEST_STRING("regmodel.cpu_table32.r2", leaves[6].get_full_name(), "name r2 must match");
    `TEST_STRING("regmodel.cpu_table32.r3", leaves[7].get_full_name(), "name r3 must match");
    `TEST_STRING("regmodel.cpu_table32.blk4.r4", leaves[8].get_full_name(), 
                                                                      "name r4 must match");
    `TEST_STRING("regmodel.cpu_table32.blk4.r5", leaves[9].get_full_name(), 
                                                                      "name r5 must match");
  endtask

  task test_address_map;
    `TEST_VALUE(32'hA0000, regmodel.get_offset("cpu_map"), "Base addr of cpu must match");
    `TEST_VALUE(32'hA0000, regmodel.cpu_reg32.get_offset("cpu_map"), 
                                                            "Start addr of reg32 must match");
    `TEST_VALUE(32'hA1000, regmodel.cpu_table32.get_offset("cpu_map"), 
                                                            "Start addr of table32 must match");
  endtask

  task test_r1_address;
    `TEST_VALUE(32'hA0100, regmodel.cpu_reg32.r1.get_offset("cpu_map"), 
                                                  "Addr of reg32.r1 must match");
  endtask

  virtual task run();
    `RUN_TEST(test_tree);
    `RUN_TEST(test_address_map);
    `RUN_TEST(test_r1_address);
  endtask

endclass
`endif
