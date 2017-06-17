`ifndef INCLUDED_test_table_reset
`define INCLUDED_test_table_reset

import srm_pkg::*;

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
    `TEST_VALUE(1, regmodel.r2.is_reset_present(), "Table must have reset");
    
    entry = regmodel.r2.entry_at(8);
    `TEST_VALUE('hff, entry.get(), "read out hard value");
  endtask


  task test_reset_set_value();
    cpu_multi_field::r2_struct_t wr_data = 8'ha5;
    entry = regmodel.r2.entry_at(13);
    entry.set(wr_data);
    `TEST_VALUE(1, regmodel.r2.get_active_entries(), "set entry allocated");
    `TEST_VALUE('ha5, entry.get(), "read out set value");
    regmodel.r2.reset("HARD"); 
    `TEST_VALUE('hff, entry.get(), "read out reset value");
    `TEST_VALUE(0, regmodel.r2.get_active_entries(), "set entry deallocated");
  endtask
  virtual task run();
    `RUN_TEST(test_get_reset_value);
    `RUN_TEST(test_reset_set_value);
  endtask

endclass
`endif
