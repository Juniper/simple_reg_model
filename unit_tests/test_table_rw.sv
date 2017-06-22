`ifndef INCLUDED_test_table_rw_sv
`define INCLUDED_test_table_rw_sv

import srm_pkg::*;
//---------------------------------------------
// Class: test_table_rw
// Test the read and write task to the table 
//---------------------------------------------

class test_table_rw extends srm_unit_test;

  cpu_table32 regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;
  srm_handle cpu_handle;

  cpu_table32::r1_struct_t wr_data, rd_data;
  srm_reg#(cpu_table32::r1_struct_t) entry;  

  function new();
    super.new("test_table_rw");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset(.addr_map_name("cpu_map"), .offset(64'h10000));

    adapter_policy = new();
    cpu_handle = new(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    adapter = new(.name("cpu_map_adapter"));
    adapter.no_response_generated = 1;
    regmodel.add_adapter(adapter);
  endfunction

  task test_write_r1;

    cpu_handle.generic_xact_status = SRM_NOT_OK; // Just for testing overwrite
    wr_data.field = 32'hdeadbeef;
    entry = regmodel.r1.entry_at(9);
    entry.write(cpu_handle, wr_data);
    `TEST_VALUE(SRM_IS_OK, cpu_handle.generic_xact_status, "read status must be ok");
    `TEST_VALUE(wr_data.field, adapter.last_data, "adapter write data must match");
    `TEST_VALUE('h10100 + 9*4, adapter.last_addr, "adapter write addr must match");
    rd_data = entry.get();
    `TEST_VALUE(wr_data.field, rd_data.field, "model data must match"); 
  endtask

  task test_write_r1_incr;

    for(int i = 0; i < regmodel.r1.get_num_entries(); i++) begin
      cpu_handle.generic_xact_status = SRM_NOT_OK; // Just for testing overwrite
      wr_data.field = i;
      entry = regmodel.r1.entry_at(i);
      entry.write(cpu_handle, wr_data);
      `TEST_VALUE(i, adapter.last_data, "adapter write data must match");
      `TEST_VALUE('h10100 + i*4, adapter.last_addr, "adapter write addr must match");
    end

    for(int i = 0; i < regmodel.r1.get_num_entries(); i++) begin
      entry = regmodel.r1.entry_at(i);
      rd_data = entry.get();
      `TEST_VALUE(i, rd_data.field, "model must get updated correctly"); 
    end
  endtask

  task test_load_r4;
    adapter.last_data = 32'h01234567;
    regmodel.blk4.r4.load(cpu_handle);
    `TEST_VALUE(10, regmodel.blk4.r4.get_num_active_entries(), "all entries must be loaded");
    for(int i = 0; i < regmodel.blk4.r4.get_num_entries(); i++) begin
      entry = regmodel.blk4.r4.entry_at(i);
      `TEST_VALUE(32'h01234567, entry.get(), "All entries must be initialized");
    end
  endtask

  task test_store_r4;
    // Initialize the table.
    for(int i = 0; i < regmodel.blk4.r4.get_num_entries(); i++) begin
      wr_data.field = i;
      entry = regmodel.blk4.r4.entry_at(i);
      entry.set(wr_data);
    end
    // Overwrite the last entry for checking.
    wr_data.field = 32'hf00dcafe;
    entry = regmodel.blk4.r4.entry_at(9);
    entry.set(wr_data);

    regmodel.blk4.r4.store(cpu_handle);
    `TEST_VALUE(10, regmodel.blk4.r4.get_num_active_entries(), "all entries must be stored");
    `TEST_VALUE(32'hf00dcafe, adapter.last_data, "model data must be written out");
    `TEST_VALUE(32'h10410 + 9*4, adapter.last_addr, "last model addr must match");
  endtask

  virtual task run();
    `RUN_TEST(test_write_r1);
    `RUN_TEST(test_write_r1_incr);
    `RUN_TEST(test_load_r4);
    `RUN_TEST(test_store_r4);
  endtask

endclass
`endif
