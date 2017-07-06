`ifndef INCLUDED_test_model_coverage_sv
`define INCLUDED_test_model_coverage_sv

import srm_pkg::*;

//
// Class: test_model_coverage
// Create a functional coverage model attached to the root node.
// Use the callback routine to update the coverage as different registers
// are accessed.
//
class test_model_coverage extends srm_unit_test;
 
  // 
  // Class: functional coverage model of dut.
  //
  class fcov_model extends srm_base_coverage;
    cpu_reg32 _regmodel;
    cpu_reg32::r1_struct_t r1_data;

    covergroup reg32_covergroup;
      coverpoint {r1_data.field == 32'hdeadbeef };
    endgroup

    function new(cpu_reg32 regmodel);
      super.new("fcov_model");
      reg32_covergroup = new;
      _regmodel = regmodel;
    endfunction

    virtual function void post_write(srm_base_reg entry);
      srm_data_t bytes = entry.get_bytes();

      // Coverage for r1
      if(entry == _regmodel.r1) begin
        r1_data = 'h0;
        for(int i = 0; i < bytes.size(); i++) begin
          r1_data[i*8 +: 8] = bytes[i];
        end
        reg32_covergroup.sample();
      end

    endfunction

  endclass

  cpu_reg32 regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;

  srm_base_handle cpu_handle;
  fcov_model fcov_inst;
  cpu_reg32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_model_coverage");
  endfunction


  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    fcov_inst = new(regmodel);
    adapter_policy = new();
    cpu_handle = new("cpu_handle");
    cpu_handle.initialize(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    adapter = new(.name("cpu_map_adapter"));
    regmodel.add_adapter(adapter);
  endfunction

  task test_model_coverage;
    // Attach the observer to the root node.
    regmodel.attach(fcov_inst);
    cpu_handle.enable_functional_coverage = 1;
    wr_data.field = 32'h0;
    regmodel.r1.write(cpu_handle, wr_data);
    `TEST_VALUE(50, $rtoi(fcov_inst.reg32_covergroup.get_coverage()), "false coverage expected.");

    wr_data.field = 32'hdeadbeef;
    regmodel.r1.write(cpu_handle, wr_data);
    `TEST_VALUE(100, $rtoi(fcov_inst.reg32_covergroup.get_coverage()), "false + true coverage expected");
  endtask

  virtual task run();
    `RUN_TEST(test_model_coverage);
  endtask

endclass
`endif
