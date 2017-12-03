`ifndef INCLUDED_test_table32_sv
`define INCLUDED_test_table32_sv


class test_table32 extends srm_unit_test;

  cpu_table32 regmodel;
  cpu_table32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_table32");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset("cpu_map", 64'h10000);
  endfunction

  task test_set_get;
    srm_component leaves[$];
    // NC verilog has a issue with function chaining. Works for vcs.
    srm_reg#(cpu_table32::r1_struct_t) entry;  
    wr_data.field = 'ha5;
    entry = regmodel.r1.entry_at(8);
    entry.set(wr_data);

    rd_data = entry.get();
    `TEST_VALUE('ha5, rd_data.field, "get data matches the set data"); 
    
    entry = regmodel.r1.entry_at(8);
    rd_data = entry.get();
    `TEST_VALUE('ha5, rd_data.field, "get data matches the set data"); 
   
  endtask
  
  task test_tree;
    srm_component leaves[$];
    regmodel.get_leaf_nodes(leaves);
    `TEST_VALUE(1, regmodel.is_root_node(), "Root node match"); 
    `TEST_VALUE(4, regmodel.num_children(), "Root node has 4 children");
    `TEST_VALUE(5, leaves.size(), "Number of leaves must match");
    `TEST_STRING("regmodel.r1", leaves[0].get_full_name(), "Name of r1 must match");
    `TEST_STRING("regmodel.r2", leaves[1].get_full_name(), "Name of r2 must match");
    `TEST_STRING("regmodel.r3", leaves[2].get_full_name(), "Name of r3 must match");
    `TEST_STRING("regmodel.blk4.r4", leaves[3].get_full_name(), "Full name r4 must match");
    `TEST_STRING("regmodel.blk4.r5", leaves[4].get_full_name(), "Full name r5 must match");
  endtask

  task test_address_nodes;
    `TEST_VALUE(32'h10000, regmodel.get_offset("cpu_map"), "Start addr of cpu must match");
    `TEST_VALUE(32'h10100, regmodel.r1.get_offset("cpu_map"), "Start addr of r1 match");
    `TEST_VALUE(32'h10200, regmodel.r2.get_offset("cpu_map"), "Start addr of r2 match");
    `TEST_VALUE(32'h10300, regmodel.r3.get_offset("cpu_map"), "Start addr of r3 match");
    `TEST_VALUE(32'h10400, regmodel.blk4.get_offset("cpu_map"), "Start addr of blk4 must match");
    `TEST_VALUE(32'h10410, regmodel.blk4.r4.get_offset("cpu_map"), "Start addr of r4 must match");
    `TEST_VALUE(32'h10440, regmodel.blk4.r5.get_offset("cpu_map"), "Start addr of r5 must match");
  endtask

  task test_address_entries;
    srm_reg#(cpu_table32::r1_struct_t) entry;  
    entry = regmodel.r1.entry_at(0);
    `TEST_VALUE(32'h10100, entry.get_offset("cpu_map"), "Addr of r1.entry#0 must match");
    entry = regmodel.r1.entry_at(9);
    `TEST_VALUE(32'h10124, entry.get_offset("cpu_map"), "Addr of r1.entry#9 must match");

    entry = regmodel.r2.entry_at(0);
    `TEST_VALUE(32'h10200, entry.get_offset("cpu_map"), "Addr of r2.entry#0 must match");
    entry = regmodel.r2.entry_at(9);
    `TEST_VALUE(32'h10224, entry.get_offset("cpu_map"), "Addr of r2.entry#9 must match");
  endtask

  task test_address_blk4_entries;
    srm_reg#(cpu_table32::r1_struct_t) entry;  
    entry = regmodel.blk4.r4.entry_at(0);
    `TEST_VALUE(32'h10410, entry.get_offset("cpu_map"), "Addr of blk4.r4.entry#0 must match");
    entry = regmodel.blk4.r4.entry_at(9);
    `TEST_VALUE(32'h10434, entry.get_offset("cpu_map"), "Addr of blk4.r4.entry#9 must match");
  endtask

  virtual task run();
    `RUN_TEST(test_set_get);
    `RUN_TEST(test_tree);
    `RUN_TEST(test_address_nodes);
    `RUN_TEST(test_address_entries);
    `RUN_TEST(test_address_blk4_entries);
  endtask

endclass
`endif
