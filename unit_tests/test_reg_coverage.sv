`ifndef INCLUDED_test_reg_coverage_sv
`define INCLUDED_test_reg_coverage_sv

import srm_pkg::*;
class test_reg_coverage extends srm_unit_test;
  
  // Define a custom coverage model.
  class reg32_fcov_model extends srm_base_observer;
    srm_generic_xact_t _xact;

    covergroup reg32_covergroup;
      coverpoint {_xact.addr };
    endgroup

    function new();
      super.new("reg32_fcov_model");
      reg32_covergroup = new();
    endfunction

    virtual function void sample(const ref srm_generic_xact_t xact);
      _xact = xact;
      reg32_covergroup.sample();
    endfunction

  endclass

  cpu_reg32 regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;

  srm_base_handle cpu_handle;
  reg32_fcov_model fcov_inst;
  cpu_reg32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_reg_coverage");
  endfunction


  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    fcov_inst = new();
    adapter_policy = new();
    cpu_handle = new("cpu_handle");
    cpu_handle.initialize(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    adapter = new(.name("cpu_map_adapter"));
    regmodel.add_adapter(adapter);
  endfunction

  task test_attach_observer;
    regmodel.attach(fcov_inst);
    `TEST_VALUE(0, regmodel.get_num_observers(), "Observer only at leaf node");
    `TEST_VALUE(1, regmodel.r1.get_num_observers(), "r1 must have 1 observer");
    `TEST_VALUE(1, regmodel.r2.get_num_observers(), "r2 must have 1 observer");
    `TEST_VALUE(1, regmodel.r3.get_num_observers(), "r3 must have 1 observer");
  endtask

  task test_r1_write_sample;
    regmodel.r1.attach(fcov_inst);
    `TEST_VALUE(1, regmodel.r1.get_num_observers(), "r1 must have 1 observer");
    `TEST_VALUE(0, regmodel.r2.get_num_observers(), "r2 must have 0 observer");
    wr_data.field = 32'hdeadbeef;
    cpu_handle.enable_functional_coverage = 1;
    regmodel.r1.write(cpu_handle, wr_data);
    `TEST_VALUE(8'hef, fcov_inst._xact.data[0] , "xact must be available for coverage");
  endtask

  task test_r1_write_not_sample;
    regmodel.r1.attach(fcov_inst);
    `TEST_VALUE(1, regmodel.r1.get_num_observers(), "r1 must have 1 observer");
    wr_data.field = 32'hdeadbeef;
    cpu_handle.enable_functional_coverage = 0;
    fcov_inst._xact.data = new[1];
    fcov_inst._xact.data[0] = 'ha5;
    regmodel.r1.write(cpu_handle, wr_data);
    `TEST_VALUE('ha5, fcov_inst._xact.data[0] , "handle must disable the sample.");
  endtask

  virtual task run();
    `RUN_TEST(test_attach_observer);
    `RUN_TEST(test_r1_write_sample);
    `RUN_TEST(test_r1_write_not_sample);
  endtask

endclass
`endif
