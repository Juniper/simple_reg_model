`ifndef INCLUDED_test_field_policies_sv
`define INCLUDED_test_field_policies_sv

import srm_pkg::*;
//---------------------------------------------
// Class: test_field_policies
// Test the read and write task to the field.
//---------------------------------------------

class test_field_policies extends srm_unit_test;

  cpu_multi_field regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;
  srm_base_handle cpu_handle;

  cpu_multi_field::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_field_policies");
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

  task test_reg_set_policy();
    srm_base_policy p;
    regmodel.set_policy("cpu_map", .policy(srm_rc_policy::get()));
    p = srm_rc_policy::get();
    `TEST_VALUE(p, regmodel.r1.f0.get_policy("cpu_map"), "Sets the register policy");
    `TEST_VALUE(p, regmodel.r1.f3.get_policy("cpu_map"), "Sets the register policy");
  endtask

  task test_table_set_policy();
    srm_base_policy p;
    cpu_multi_field::r2_table::r2_entry  entry;

    regmodel.set_policy("cpu_map", .policy(srm_rc_policy::get()));
    entry = regmodel.r2.entry_at(3);
    entry.dump();
    p = srm_rc_policy::get();
    `TEST_VALUE(p, entry.f0.get_policy("cpu_map"), "Sets the table entry policy for f0");
    `TEST_VALUE(p, entry.f4.get_policy("cpu_map"), "Sets the table entry policy for f4");
  endtask

  task test_read_only_field();
    bit[7:0] rd_byte;
    
    regmodel.reset("HARD");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "Setup the register");

    regmodel.r1.f0.set_policy("cpu_map", srm_ro_policy::get());

    regmodel.r1.f0.write(cpu_handle, 'hff);
    
    `TEST_VALUE('h67, regmodel.r1.f0.get(), "field 0 unchanged since read only");
  endtask

  task test_read_clear_field();
    bit[7:0] rd_byte;
    
    regmodel.reset("HARD");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "Setup the register");

    regmodel.r1.f0.set_policy("cpu_map", srm_rc_policy::get());

    regmodel.r1.f0.write(cpu_handle, 'hff);
    `TEST_VALUE('h67, regmodel.r1.f0.get(), "write has no effect");

    adapter.last_data = 'h01234567; // Model the dut behavior
    regmodel.r1.f0.read(cpu_handle, rd_byte);
    `TEST_VALUE('h67, rd_byte, "Read returns data from design.");
    `TEST_VALUE('h0, regmodel.r1.f0.get(), "Read clears the field.");

  endtask

  task test_read_set_field();
    bit[7:0] rd_byte;
    
    regmodel.reset("HARD");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "Setup the register");

    regmodel.r1.f0.set_policy("cpu_map", srm_rs_policy::get());

    regmodel.r1.f0.write(cpu_handle, 'hff);
    `TEST_VALUE('h67, regmodel.r1.f0.get(), "write has no effect");

    adapter.last_data = 'h01234567; // Model the dut behavior
    regmodel.r1.f0.read(cpu_handle, rd_byte);
    `TEST_VALUE('h67, rd_byte, "Read returns data from design.");
    `TEST_VALUE('hff, regmodel.r1.f0.get(), "Read sets the field.");

  endtask

  task test_write_read_clear_field();
    bit[7:0] rd_byte;
    
    regmodel.reset("HARD");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "Setup the register");

    regmodel.r1.f0.set_policy("cpu_map", srm_wrc_policy::get());

    regmodel.r1.f0.write(cpu_handle, 'hff);
    `TEST_VALUE('hff, regmodel.r1.f0.get(), "write as is");

    regmodel.r1.f0.read(cpu_handle, rd_byte);
    `TEST_VALUE('hff, rd_byte, "Read returns data from design.");
    `TEST_VALUE('h0, regmodel.r1.f0.get(), "Read clears the field.");
  endtask

  task test_write_1_clear_field();
    bit[7:0] rd_byte;
    
    regmodel.reset("HARD");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "Setup the register");

    regmodel.r1.f0.set_policy("cpu_map", srm_w1c_policy::get());

    regmodel.r1.f0.write(cpu_handle, 'ha5);
    // 1 to clear: 0x67 with 0xa5
    `TEST_VALUE('h42, regmodel.r1.f0.get(), "write as is");

  endtask

  task test_write_1_toggle_field();
    bit[7:0] rd_byte;
    
    regmodel.reset("HARD");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "Setup the register");

    regmodel.r1.f0.set_policy("cpu_map", srm_w1t_policy::get());
    regmodel.r1.f0.write(cpu_handle, 'ha5);
    // 1 to clear: 0x67 with 0xa5
    `TEST_VALUE('hc2, regmodel.r1.f0.get(), "write as is");

  endtask

  virtual task run();
    `RUN_TEST(test_reg_set_policy);
    `RUN_TEST(test_table_set_policy);
    `RUN_TEST(test_read_only_field);
    `RUN_TEST(test_read_clear_field);
    `RUN_TEST(test_read_set_field);
    `RUN_TEST(test_write_read_clear_field);
    `RUN_TEST(test_write_1_clear_field);
    `RUN_TEST(test_write_1_toggle_field);
  endtask

endclass
`endif
