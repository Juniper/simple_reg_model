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
  srm_handle cpu_handle;

  cpu_reg32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_reg_rw");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset(.addr_map_name("cpu_map"), .offset(64'h10000));

    adapter_policy = new();
    cpu_handle = new(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    cpu_handle.auto_predict_model = 1;
    adapter = new(.addr_map_name("cpu_map"));
    regmodel.add_adapter(adapter);
  endfunction

  task test_write_r1;
    wr_data.field = 32'hdeadbeef;
    regmodel.r1.write(cpu_handle, wr_data);
    rd_data = regmodel.r1.get();
    `TEST_VALUE(32'hdeadbeef, rd_data.field, "written data must match"); 
  endtask

  virtual task run();
    `RUN_TEST(test_write_r1);
  endtask

endclass
`endif
