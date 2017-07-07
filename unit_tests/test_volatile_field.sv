`ifndef INCLUDED_test_volatile_field_sv
`define INCLUDED_test_volatile_field_sv

import srm_pkg::*;

//----------------------------------------------------
// CLASS: test_volatile_field
// Test volatile field in both register and table.
//----------------------------------------------------

class test_volatile_field extends srm_unit_test;

  cpu_volatile_field regmodel;
  
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;
  srm_base_handle cpu_handle;
  cpu_volatile_field::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_volatile_field");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    adapter_policy = new();
    cpu_handle = new();
    cpu_handle.initialize(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    adapter = new(.name("cpu_map_adapter"));
    regmodel.add_adapter(adapter);
  endfunction

  task test_reg_volatile;
    regmodel.reset("BIST");
    regmodel.r1.store(cpu_handle);
    `TEST_VALUE(32'h89abcdef, adapter.last_data, "ensure that reg data is written");

    regmodel.r1.f0.set('h0);
    regmodel.r1.f2.set('h0);
    `TEST_VALUE(32'h8900cd00, regmodel.r1.get(), "ensure model data is different");

    regmodel.r1.read(cpu_handle, rd_data);
    `TEST_VALUE(SRM_IS_OK, cpu_handle.generic_xact_status, "read status must be ok");
    `TEST_VALUE(32'h89abcdef, regmodel.r1.get(), "read data must be updated in model");
  endtask

  task test_table_volatile;
    cpu_volatile_field::r2_table::r2_entry entry;  
    cpu_volatile_field::r2_struct_t rd_data;

    regmodel.reset("BIST");
    regmodel.r2.store(cpu_handle);
    `TEST_VALUE(8'hff, adapter.last_data, "ensure that table data is written");

    entry = regmodel.r2.entry_at(13);
    entry.f2.set('h0);
    entry.f4.set('h0);
    `TEST_VALUE(8'h47, entry.get(), "ensure table model data is different");

    entry.read(cpu_handle, rd_data);
    `TEST_VALUE(SRM_IS_OK, cpu_handle.generic_xact_status, "read status must be ok");
    `TEST_VALUE(8'hff, entry.get(), "read table data must be updated in model");
  endtask


  task test_table_debug;
    cpu_volatile_field::r2_table::r2_entry entry;  
    cpu_volatile_field::r2_struct_t rd_data;
    regmodel.reset("BIST");
    regmodel.r2.store(cpu_handle);
    `TEST_VALUE(8'hff, adapter.last_data, "ensure that table data is written");
  endtask
  
  virtual task run();
    //`RUN_TEST(test_reg_volatile);
    //`RUN_TEST(test_table_volatile);
    `RUN_TEST(test_table_debug);
  endtask

endclass

`endif
