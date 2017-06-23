`ifndef INCLUDED_test_field_rw_sv
`define INCLUDED_test_field_rw_sv

import srm_pkg::*;
//---------------------------------------------
// Class: test_field_rw
// Test the read and write task to the field.
//---------------------------------------------

class test_field_rw extends srm_unit_test;

  cpu_multi_field regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;
  srm_handle cpu_handle;

  cpu_multi_field::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_field_rw");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset(.addr_map_name("cpu_map"), .offset(64'h10000));

    adapter_policy = new();
    cpu_handle = new(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    adapter = new(.name("cpu_map_adapter"));
    regmodel.add_adapter(adapter);
  endfunction

  task test_reg_field_write();
    regmodel.reset("HARD");
    regmodel.r1.store(cpu_handle);
    `TEST_VALUE('h01234567, regmodel.r1.get(), "Setup the register");

    regmodel.r1.f1.write(cpu_handle, 'h0);
    
    `TEST_VALUE(4'b0010, adapter.byte_enables, "Byte enable for f1 should be off");
    `TEST_VALUE('h01230067, regmodel.r1.get(), "field 1 must be updated");
  endtask

  task test_reg_field_read();
    bit[7:0] value;
    regmodel.reset("HARD");
    regmodel.r1.store(cpu_handle);
    
    regmodel.r1.f2.read(cpu_handle, value);
    
    `TEST_VALUE(4'b0100, adapter.byte_enables, "Byte enable for f2 should be off");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "read field should not change the contents");
    `TEST_VALUE('h23, value, "read field should not change the contents");
  endtask

  virtual task run();
    `RUN_TEST(test_reg_field_write);
    `RUN_TEST(test_reg_field_read);
  endtask

endclass
`endif
