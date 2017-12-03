`ifndef INCLUDED_test_table_reset
`define INCLUDED_test_table_reset



class test_table_reset extends srm_unit_test;

  cpu_multi_field regmodel;
  srm_reg#(cpu_multi_field::r2_struct_t) entry;  

  function new();
    super.new("test_table_reset");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
  endfunction

  task test_get_reset_value();
    `TEST_VALUE(1, regmodel.r2.is_resettable("HARD"), "Table must be resettable");
    `TEST_VALUE(1, regmodel.r2.is_resettable("HARD"), "Table must have reset");
    entry = regmodel.r2.entry_at(8);
    `TEST_VALUE('h0, entry.get(), "read out hard value");
    regmodel.reset("BIST");    
    entry = regmodel.r2.entry_at(8);
    `TEST_VALUE('hff, entry.get(), "read out bist value");
  endtask


  task test_reset_set_value();
    cpu_multi_field::r2_struct_t wr_data = 8'ha5;
    entry = regmodel.r2.entry_at(13);
    entry.set(wr_data);
    `TEST_VALUE(1, regmodel.r2.get_num_active_entries(), "set entry allocated");
    `TEST_VALUE('ha5, entry.get(), "read out set value");
    regmodel.r2.reset("BIST"); 
    `TEST_VALUE('hff, entry.get(), "read out reset value");
  endtask

  task test_top_multi_reset();
   regmodel.reset("BIST"); 
   entry = regmodel.r2.entry_at(1);
   `TEST_VALUE('hff, entry.get(), "read out bist value");
   regmodel.reset("HARD"); 
   `TEST_VALUE('h0, entry.get(), "read out hard value");
  endtask

  virtual task run();
    `RUN_TEST(test_get_reset_value);
    `RUN_TEST(test_reset_set_value);
    `RUN_TEST(test_top_multi_reset);
  endtask

endclass
`endif
