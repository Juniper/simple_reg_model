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
      reg32_covergroup = new();
    endfunction

    virtual function void sample(const ref srm_generic_xact_t xact);
      _xact = xact;
      reg32_covergroup.sample();
    endfunction

  endclass

  cpu_reg32 regmodel;
  reg32_fcov_model fcov_inst;
  cpu_reg32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_reg_coverage");
  endfunction


  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    fcov_inst = new();
    regmodel.attach(fcov_inst);
  endfunction

  task test_attach_observer;
  endtask

  virtual task run();
    `RUN_TEST(test_attach_observer);
  endtask

endclass
`endif
