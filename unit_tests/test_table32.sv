`ifndef INCLUDED_test_table32_sv
`define INCLUDED_test_table32_sv

import srm_pkg::*;
class test_table32 extends srm_unit_test;

  cpu_table32 regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;
  srm_handle cpu_handle;

  cpu_table32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_table32");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    adapter_policy = new();
    cpu_handle = new(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    cpu_handle.auto_predict_model = 1;
    adapter = new();
    regmodel.add_adapter(adapter);
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
   
    // Make sure that the tree has not changed.
    regmodel.get_leaf_nodes(leaves);
    `TEST_VALUE(1, leaves.size(), "Only 1 table as leaf");
  endtask
  
  task test_tree;
    srm_component leaves[$];
    regmodel.get_leaf_nodes(leaves);
    `TEST_VALUE(1, regmodel.is_root_node(), "Root node match"); 
    `TEST_VALUE(3, regmodel.num_children(), "Root node has 3 children");
    `TEST_VALUE(3, leaves.size(), "Number of leaves must match");
    `TEST_STRING("regmodel.r1", leaves[0].get_full_name(), "Name of r1 must match");
    `TEST_STRING("regmodel.r2", leaves[0].get_full_name(), "Name of r2 must match");
    `TEST_STRING("regmodel.r3", leaves[0].get_full_name(), "Name of r3 must match");
  endtask

  task test_address_map;
    srm_reg#(cpu_table32::r1_struct_t) entry;  
    `TEST_VALUE(32'h10000, regmodel.get_address("cpu_map"), "Start addr of cpu must match");
    `TEST_VALUE(32'h10100, regmodel.r1.get_address("cpu_map"), "Start addr of r1 match");
    `TEST_VALUE(32'h10200, regmodel.r2.get_address("cpu_map"), "Start addr of r2 match");
    `TEST_VALUE(32'h10300, regmodel.r3.get_address("cpu_map"), "Start addr of r3 match");
    entry = regmodel.r1.entry_at(0);
    `TEST_VALUE(32'h10100, entry.get_address("cpu_map"), "Start addr of entry#0 must match");
  endtask


  virtual task run();
    //`RUN_TEST(test_set_get);
    //`RUN_TEST(test_tree);
    `RUN_TEST(test_address_map);
  endtask

endclass
`endif
