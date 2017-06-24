`ifndef INCLUDED_test_reg_rw_sv
`define INCLUDED_test_reg_rw_sv

import srm_pkg::*;
//---------------------------------------------
// Class: test_reg_rw
// Test the read and write task to the register
//---------------------------------------------

class test_reg_rw extends srm_unit_test;

  cpu_reg32 regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;
  srm_base_handle cpu_handle;

  cpu_reg32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_reg_rw");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset(.addr_map_name("cpu_map"), .offset(64'h10000));

    adapter_policy = new();
    cpu_handle = new("cpu_handle");
    cpu_handle.initialize(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    adapter = new(.name("cpu_map_adapter"));
    regmodel.add_adapter(adapter);
  endfunction

  task test_write_r1;
    wr_data.field = 32'hdeadbeef;
    cpu_handle.generic_xact_status = SRM_NOT_OK; // Just for testing overwrite
    regmodel.r1.write(cpu_handle, wr_data);
    rd_data = regmodel.r1.get();
    `TEST_VALUE(32'hdeadbeef, rd_data.field, "written data must match"); 
    `TEST_VALUE(SRM_IS_OK, cpu_handle.generic_xact_status, "write status must be ok");
  endtask

  task test_field_write_r1;
    cpu_handle.generic_xact_status = SRM_NOT_OK; // Just for testing overwrite
    regmodel.r1.write(cpu_handle, 'h0);
    regmodel.r1.field.write(cpu_handle, 'h01234567);
    rd_data = regmodel.r1.get();
    `TEST_VALUE(32'h01234567, rd_data.field, "written data must match"); 
    `TEST_VALUE(SRM_IS_OK, cpu_handle.generic_xact_status, "write status must be ok");
  endtask

  task test_read_r1;
    wr_data.field = 32'h01234567;
    cpu_handle.generic_xact_status = SRM_NOT_OK; // Just for testing overwrite

    // Ensure that the model and design have the same data.
    regmodel.r1.set(wr_data);
    adapter.last_data = wr_data.field;

    regmodel.r1.read(cpu_handle, rd_data);
    `TEST_VALUE(32'h01234567, rd_data.field, "read data must match"); 
    `TEST_VALUE(SRM_IS_OK, cpu_handle.generic_xact_status, "read status must be ok");
  endtask

  task test_field_read_r1;
    adapter.last_data = 'h01234567;
    regmodel.r1.set('h01234567);
    regmodel.r1.field.read(cpu_handle, rd_data);
    `TEST_VALUE(32'h01234567, regmodel.r1.field.get(), "written data must match"); 
    `TEST_VALUE(SRM_IS_OK, cpu_handle.generic_xact_status, "write status must be ok");
  endtask

  task test_mismatch_read_r1;
    cpu_reg32::r1_struct_t temp_data;
    wr_data.field = 32'h01234567;
    cpu_handle.generic_xact_status = SRM_NOT_OK; // Just for testing overwrite

    // Ensure that the model and design have DIFFERENT data.
    temp_data.field = 32'h0;
    regmodel.r1.set(temp_data);
    adapter.last_data = wr_data.field;
    cpu_handle.skip_read_error_msg = 1;

    regmodel.r1.read(cpu_handle, rd_data);
    `TEST_VALUE(32'h01234567, regmodel.r1.field.get(), "read data must return the RTL data"); 
    `TEST_VALUE(SRM_READ_DATA_MISMATCH, cpu_handle.generic_xact_status, "read status must mismatch");
    `TEST_VALUE(1, cpu_handle.error_msgs.size(), "Error must be generated");
  endtask

  task test_peek_r1;
    cpu_reg32::r1_struct_t temp_data;
    wr_data.field = 32'h01234567;

    // Ensure that the model and design have DIFFERENT data.
    temp_data.field = 32'h0;
    regmodel.r1.set(temp_data);
    adapter.last_data = wr_data.field;

    regmodel.r1.peek(cpu_handle, rd_data);
    `TEST_VALUE(32'h01234567, rd_data.field, "peek data must return the RTL data"); 
  endtask
    
  task test_load_r1;
    cpu_reg32::r1_struct_t temp_data;
    wr_data.field = 32'h01234567;

    // Ensure that the model and design have DIFFERENT data.
    temp_data.field = 32'h0;
    regmodel.r1.set(temp_data);
    adapter.last_data = wr_data.field;

    regmodel.r1.load(cpu_handle);
    rd_data = regmodel.r1.get();
    `TEST_VALUE(32'h01234567, rd_data.field, "load data must return the RTL data"); 
  endtask
  
  task test_store_r1;
    wr_data.field = 32'h01234567;

    regmodel.r1.set(wr_data);
    regmodel.r1.store(cpu_handle);
    `TEST_VALUE(32'h01234567, adapter.last_data, "store must write data"); 
  endtask
  
  virtual task run();
    `RUN_TEST(test_write_r1);
    `RUN_TEST(test_field_write_r1);
    `RUN_TEST(test_read_r1);
    `RUN_TEST(test_field_read_r1);
    `RUN_TEST(test_peek_r1);
    `RUN_TEST(test_mismatch_read_r1);
    `RUN_TEST(test_load_r1);
    `RUN_TEST(test_store_r1);
  endtask

endclass
`endif
