`ifndef INCLUDED_test_leaf_policies_sv
`define INCLUDED_test_leaf_policies_sv

import srm_pkg::*;
//---------------------------------------------
// Class: test_leaf_policies
// Test the policies defined on registers and tables
//---------------------------------------------

class test_leaf_policies extends srm_unit_test;

  cpu_multi_field regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;
  srm_base_handle cpu_handle;

  cpu_multi_field::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_leaf_policies");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset(.addr_map_name("cpu_map"), .offset(64'h10000));

    adapter_policy = new();
    cpu_handle = new();
    cpu_handle.initialize(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    adapter = new(.name("cpu_map_adapter"));
    regmodel.add_adapter(adapter);
  endfunction


  task test_read_only_reg();
    bit[7:0] rd_byte;
    
    regmodel.reset("HARD");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "Setup the register");

    regmodel.r1.set_policy("cpu_map", srm_ro_policy::get());

    regmodel.r1.write(cpu_handle, 'h0);
    
    `TEST_VALUE('h01234567, regmodel.r1.get(), "reg unchanged since read only");
  endtask

  task test_w0crs_table();
    srm_base_policy p;
    bit[7:0] temp;
    cpu_multi_field::r2_table::r2_entry  entry;

    regmodel.r2.set_policy("cpu_map", srm_w0crs_policy::get());

    entry = regmodel.r2.entry_at(1);

    entry.set(8'ha5);
    entry.write(cpu_handle, 8'h24);
    // 1- no effect, 0-clears
    `TEST_VALUE(8'h24, entry.get(), "entry updated by write policy");

    adapter.last_data = 'h24; // Model the dut behavior
    entry.read(cpu_handle, temp);
    `TEST_VALUE('h24, temp, "Read entry returns the rtl data");
    `TEST_VALUE('hff, entry.get(), "Policy must set entry");

  endtask
  
  virtual task run();
    `RUN_TEST(test_read_only_reg);
    `RUN_TEST(test_w0crs_table);
  endtask

endclass
`endif
