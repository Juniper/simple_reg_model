`ifndef INCLUDED_test_table_coverage_sv
`define INCLUDED_test_table_coverage_sv

import srm_pkg::*;
class test_table_coverage extends srm_unit_test;
  
  // Define a custom coverage model.
  class r1_fcov_model extends srm_base_coverage;
    cpu_table32::r1_struct_t data;
    srm_addr_t index;
    srm_addr_t xact_addr;

    covergroup r1_data_cg;
      coverpoint {data.field == 32'hdeadbeef };
    endgroup

    covergroup r1_index_cg;
      coverpoint {index == 9};
    endgroup


    virtual function void post_write(srm_base_reg entry);
      srm_data_t bytes = entry.get_bytes();
      data = 'h0;
      for(int i = 0; i < bytes.size(); i++) begin
        data[i*8 +: 8] = bytes[i];
      end
      index = entry.get_index();
      r1_data_cg.sample();
      r1_index_cg.sample();
    endfunction

    covergroup r1_addr_cg;
      coverpoint {xact_addr  == 'h100};
    endgroup

    virtual function void sample_xact(const ref srm_generic_xact_t xact);
      xact_addr = xact.addr;
      r1_addr_cg.sample();
    endfunction

    function new();
      super.new("r1_fcov_model");
      r1_data_cg = new;
      r1_index_cg = new;
      r1_addr_cg = new;
    endfunction
  endclass

  cpu_table32 regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;

  srm_base_handle cpu_handle;
  r1_fcov_model fcov_inst;
  cpu_table32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_table_coverage");
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
    `TEST_VALUE(0, regmodel.get_num_coverage_cbs(), "Observer only at leaf node");
    `TEST_VALUE(1, regmodel.r1.get_num_coverage_cbs(), "r1 must have 1 observer");
    `TEST_VALUE(1, regmodel.r2.get_num_coverage_cbs(), "r2 must have 1 observer");
    `TEST_VALUE(1, regmodel.r3.get_num_coverage_cbs(), "r3 must have 1 observer");
    `TEST_VALUE(1, regmodel.blk4.r4.get_num_coverage_cbs(), "r4 must have 1 observer");
    `TEST_VALUE(1, regmodel.blk4.r5.get_num_coverage_cbs(), "r5 must have 1 observer");
  endtask

  task test_detach_observer;
    regmodel.attach(fcov_inst);
    `TEST_VALUE(1, regmodel.blk4.r5.get_num_coverage_cbs(), "r5 must have 1 observer");
    regmodel.detach(fcov_inst);
    `TEST_VALUE(0, regmodel.get_num_coverage_cbs(), "Observer only at leaf node");
    `TEST_VALUE(0, regmodel.r1.get_num_coverage_cbs(), "r1 must have 0 observer");
    `TEST_VALUE(0, regmodel.r2.get_num_coverage_cbs(), "r2 must have 0 observer");
    `TEST_VALUE(0, regmodel.r3.get_num_coverage_cbs(), "r3 must have 0 observer");
    `TEST_VALUE(0, regmodel.blk4.r4.get_num_coverage_cbs(), "r4 must have 0 observer");
    `TEST_VALUE(0, regmodel.blk4.r5.get_num_coverage_cbs(), "r5 must have 0 observer");
  endtask

  task test_detach_all;
    regmodel.attach(fcov_inst);
    `TEST_VALUE(1, regmodel.blk4.r5.get_num_coverage_cbs(), "r5 must have 1 observer");
    regmodel.detach_all();
    `TEST_VALUE(0, regmodel.blk4.r4.get_num_coverage_cbs(), "r4 must have 0 observer");
    `TEST_VALUE(0, regmodel.blk4.r5.get_num_coverage_cbs(), "r5 must have 0 observer");
  endtask

  task test_r1_write_sample;
    srm_reg#(cpu_table32::r1_struct_t) entry;  

    cpu_handle.enable_functional_coverage = 1;
    regmodel.r1.attach(fcov_inst);
    `TEST_VALUE(1, regmodel.r1.get_num_coverage_cbs(), "r1 must have 1 observer");

    entry = regmodel.r1.entry_at(0);
    wr_data.field = 32'h0;
    entry.write(cpu_handle, wr_data);
    `TEST_VALUE(50, $rtoi(fcov_inst.r1_addr_cg.get_coverage()), "r1 addr coverage achieved");
    `TEST_VALUE(50, $rtoi(fcov_inst.r1_data_cg.get_coverage()), "false data coverage achieved");
    `TEST_VALUE(50, $rtoi(fcov_inst.r1_index_cg.get_coverage()), "false addr coverage achieved");

    entry = regmodel.r1.entry_at(9);
    wr_data.field = 32'hdeadbeef;
    entry.write(cpu_handle, wr_data);
    `TEST_VALUE(100, $rtoi(fcov_inst.r1_data_cg.get_coverage()), "data coverage achieved");
    `TEST_VALUE(100, $rtoi(fcov_inst.r1_index_cg.get_coverage()), "addr coverage achieved");
  endtask

  virtual task run();
    `RUN_TEST(test_attach_observer);
    `RUN_TEST(test_detach_observer);
    `RUN_TEST(test_detach_all);
    `RUN_TEST(test_r1_write_sample);
  endtask

endclass
`endif
