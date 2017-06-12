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
    `TEST_VALUE(1, regmodel.num_children(), "Root node has 1 child");
    `TEST_VALUE(1, leaves.size(), "Only 1 table as leaf");
    `TEST_STRING("regmodel.r1", leaves[0].get_full_name(), "Full name must match");
  endtask

  task test_address_map;
    srm_reg#(cpu_table32::r1_struct_t) entry;  
    `TEST_VALUE(32'h10000, regmodel.get_address("cpu_map"), "Start addr of cpu must match");
    `TEST_VALUE(32'h10100, regmodel.r1.get_address("cpu_map"), "Start addr of table match");
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
