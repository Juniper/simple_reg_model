`ifndef INCLUDED_test_reg_reset
`define INCLUDED_test_reg_reset



class test_reg_reset extends srm_unit_test;

  cpu_multi_field regmodel;

  function new();
    super.new("test_reg_reset");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
  endfunction

  task test_get_reset_value();
    `TEST_VALUE(1, regmodel.r1.is_resettable("HARD"), "R1 must be resettable");
    `TEST_VALUE(1, regmodel.r1.is_resettable("HARD"), "R1 must have reset");
    `TEST_VALUE('h01234567, regmodel.r1.get(), "read out hard value");
  endtask

  task test_reset_set_value();
    cpu_multi_field::r1_struct_t wr_data = 32'hf00dcafe; 
    regmodel.r1.set(wr_data);
    `TEST_VALUE('hf00dcafe, regmodel.r1.get(), "read out set value");
    regmodel.r1.reset("BIST"); 
    `TEST_VALUE('h89abcdef, regmodel.r1.get(), "read out bist value");
  endtask

  task test_multi_reset();
   regmodel.r1.reset("BIST"); 
   `TEST_VALUE('h89abcdef, regmodel.r1.get(), "read out bist value");
   regmodel.r1.reset("HARD"); 
   `TEST_VALUE('h01234567, regmodel.r1.get(), "read out hard value");
  endtask

  task test_top_multi_reset();
   regmodel.reset("BIST"); 
   `TEST_VALUE('h89abcdef, regmodel.r1.get(), "read out bist value");
   regmodel.reset("HARD"); 
   `TEST_VALUE('h01234567, regmodel.r1.get(), "read out hard value");
  endtask

  virtual task run();
    `RUN_TEST(test_get_reset_value);
    `RUN_TEST(test_reset_set_value);
    `RUN_TEST(test_multi_reset);
    `RUN_TEST(test_top_multi_reset);
  endtask

endclass
`endif
