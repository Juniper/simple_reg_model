`ifndef INCLUDED_test_field_access_sv
`define INCLUDED_test_field_access_sv

import srm_pkg::*;

class test_field_access extends srm_unit_test;

  cpu_multi_field regmodel;
  cpu_multi_field::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_field_access");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
  endfunction

  task test_reg_field_set();
    regmodel.r1.f0.set('hef);
    rd_data = regmodel.r1.get();
    `TEST_VALUE('hef, rd_data, "Field 0 must match");

    regmodel.r1.f1.set('hbe);
    rd_data = regmodel.r1.get();
    `TEST_VALUE('hbeef, rd_data, "Field 1,0 must match");

    regmodel.r1.f2.set('had);
    rd_data = regmodel.r1.get();
    `TEST_VALUE('hadbeef, rd_data, "Field 2,1,0 must match");

    regmodel.r1.f3.set('hde);
    rd_data = regmodel.r1.get();
    `TEST_VALUE('hdeadbeef, rd_data, "Field 3, 2,1,0 must match");
  endtask

  task test_reg_field_get();
    wr_data = 32'hf00dcafe;
    regmodel.r1.set(wr_data);
    `TEST_VALUE('hfe, regmodel.r1.f0.get(), "Field 0 get must match");
    `TEST_VALUE('hca, regmodel.r1.f1.get(), "Field 1 get must match");
    `TEST_VALUE('h0d, regmodel.r1.f2.get(), "Field 2 get must match");
    `TEST_VALUE('hf0, regmodel.r1.f3.get(), "Field 3 get must match");
  endtask

  task test_table_field_set();
    cpu_multi_field::r2_table::r2_entry  entry;

    entry = regmodel.r2.entry_at(13);

    entry.f0.set('h1);
    entry = regmodel.r2.entry_at(13);
    rd_data = entry.get();
    `TEST_VALUE('h1, rd_data, "Field 0 get must match");

    entry.f1.set('h3);
    entry = regmodel.r2.entry_at(13);
    rd_data = entry.get();
    `TEST_VALUE('h7, rd_data, "Field 0,1 get must match");

    entry.f2.set('h7);
    entry = regmodel.r2.entry_at(13);
    rd_data = entry.get();
    `TEST_VALUE('h3f, rd_data, "Field 0,1,2 get must match");

    entry.f3.set('h1);
    entry = regmodel.r2.entry_at(13);
    rd_data = entry.get();
    `TEST_VALUE('h7f, rd_data, "Field 0,1,2,3 get must match");

    entry.f4.set('h1);
    entry = regmodel.r2.entry_at(13);
    rd_data = entry.get();
    `TEST_VALUE('hff, rd_data, "Field 0,1,2,3,4 get must match");

  endtask
  task test_table_field_get();
    cpu_multi_field::r2_table::r2_entry  entry;
    cpu_multi_field::r2_struct_t exp_data;
    bit[7:0] got_data;
    
    exp_data.f4 = 1;
    exp_data.f3 = 0;
    exp_data.f2 = 5;
    exp_data.f1 = 2;
    exp_data.f0 = 0;

    entry = regmodel.r2.entry_at(1);
    entry.set(exp_data);

    entry = regmodel.r2.entry_at(1);
    `TEST_VALUE(exp_data.f0, entry.f0.get(), "Field 0 get must match");
    `TEST_VALUE(exp_data.f1, entry.f1.get(), "Field 1 get must match");
    `TEST_VALUE(exp_data.f2, entry.f2.get(), "Field 2 get must match");
    `TEST_VALUE(exp_data.f3, entry.f3.get(), "Field 3 get must match");
    `TEST_VALUE(exp_data.f4, entry.f4.get(), "Field 4 get must match");

  endtask

  virtual task run();
    `RUN_TEST(test_reg_field_set);
    `RUN_TEST(test_reg_field_get);
    `RUN_TEST(test_table_field_set);
    `RUN_TEST(test_table_field_get);
  endtask

endclass

`endif
