`ifndef INCLUDED_test_reg_coverage_sv
`define INCLUDED_test_reg_coverage_sv

import srm_pkg::*;
class test_reg_coverage extends srm_unit_test;
  
  // Define a custom coverage model.
  class r1_fcov_model extends srm_base_coverage;
    cpu_reg32::r1_struct_t data;

    covergroup reg32_wr_cg;
      coverpoint {data.field == 32'hdeadbeef };
    endgroup

    covergroup reg32_rd_cg;
      coverpoint {data.field == 32'hdeadbeef };
    endgroup

    function new();
      super.new("r1_fcov_model");
      reg32_wr_cg = new;
      reg32_rd_cg = new;
    endfunction

    virtual function void post_write(srm_base_reg entry);
      srm_data_t bytes = entry.get_bytes();
      data = 'h0;
      for(int i = 0; i < bytes.size(); i++) begin
        data[i*8 +: 8] = bytes[i];
      end
      reg32_wr_cg.sample();
    endfunction

    virtual function void post_read(srm_base_reg entry);
      srm_data_t bytes = entry.get_bytes();
      data = 'h0;
      for(int i = 0; i < bytes.size(); i++) begin
        data[i*8 +: 8] = bytes[i];
      end
      reg32_rd_cg.sample();
    endfunction

  endclass

  class r2_fcov_model extends srm_base_coverage;
    cpu_reg32::r1_struct_t data;

    covergroup reg32_wr_cg;
      coverpoint {data.field == 32'hdeadbeef };
    endgroup

    covergroup reg32_rd_cg;
      coverpoint {data.field == 32'hdeadbeef };
    endgroup

    function new();
      super.new("r1_fcov_model");
      reg32_wr_cg = new;
      reg32_rd_cg = new;
    endfunction

    virtual function void post_write(srm_base_reg entry);
      srm_data_t bytes = entry.get_bytes();
      data = 'h0;
      for(int i = 0; i < bytes.size(); i++) begin
        data[i*8 +: 8] = bytes[i];
      end
      reg32_wr_cg.sample();
    endfunction

    virtual function void post_read(srm_base_reg entry);
      srm_data_t bytes = entry.get_bytes();
      data = 'h0;
      for(int i = 0; i < bytes.size(); i++) begin
        data[i*8 +: 8] = bytes[i];
      end
      reg32_rd_cg.sample();
    endfunction

  endclass
  cpu_reg32 regmodel;
  dummy_adapter adapter;
  first_adapter_policy adapter_policy;

  srm_base_handle cpu_handle;
  r1_fcov_model r1_fcov;
  r2_fcov_model r2_fcov;
  cpu_reg32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_reg_coverage");
    r1_fcov = new();
    r2_fcov = new();
  endfunction


  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    adapter_policy = new();
    cpu_handle = new("cpu_handle");
    cpu_handle.initialize(.adapter_policy(adapter_policy), .addr_map_name("cpu_map"));
    adapter = new(.name("cpu_map_adapter"));
    regmodel.add_adapter(adapter);
  endfunction

  task test_attach_observer;
    regmodel.attach(r1_fcov);
    `TEST_VALUE(0, regmodel.get_num_coverage_cbs(), "Observer only at leaf node");
    `TEST_VALUE(1, regmodel.r1.get_num_coverage_cbs(), "r1 must have 1 observer");
    `TEST_VALUE(1, regmodel.r2.get_num_coverage_cbs(), "r2 must have 1 observer");
    `TEST_VALUE(1, regmodel.r3.get_num_coverage_cbs(), "r3 must have 1 observer");
  endtask

  task test_detach_observer;
    regmodel.attach(r1_fcov);
    `TEST_VALUE(1, regmodel.r3.get_num_coverage_cbs(), "r3 must have 1 observer");
    regmodel.detach(r1_fcov);
    `TEST_VALUE(0, regmodel.get_num_coverage_cbs(), "Observer only at leaf node");
    `TEST_VALUE(0, regmodel.r1.get_num_coverage_cbs(), "r1 must have 0 observer");
    `TEST_VALUE(0, regmodel.r2.get_num_coverage_cbs(), "r2 must have 0 observer");
    `TEST_VALUE(0, regmodel.r3.get_num_coverage_cbs(), "r3 must have 0 observer");
  endtask

  task test_detach_all;
    regmodel.attach(r1_fcov);
    `TEST_VALUE(1, regmodel.r3.get_num_coverage_cbs(), "r3 must have 1 observer");
    regmodel.detach_all();
    `TEST_VALUE(0, regmodel.get_num_coverage_cbs(), "Observer only at leaf node");
    `TEST_VALUE(0, regmodel.r1.get_num_coverage_cbs(), "r1 must have 0 observer");
    `TEST_VALUE(0, regmodel.r2.get_num_coverage_cbs(), "r2 must have 0 observer");
    `TEST_VALUE(0, regmodel.r3.get_num_coverage_cbs(), "r3 must have 0 observer");
  endtask

  task test_r1_write_sample;
    regmodel.r1.attach(r1_fcov);
    `TEST_VALUE(1, regmodel.r1.get_num_coverage_cbs(), "r1 must have 1 observer");
    `TEST_VALUE(0, regmodel.r2.get_num_coverage_cbs(), "r2 must have 0 observer");
    wr_data.field = 32'h0;
    regmodel.r1.write(cpu_handle, wr_data);

    cpu_handle.enable_functional_coverage = 0;
    wr_data.field = 32'hdeadbeef;
    regmodel.r1.write(cpu_handle, wr_data);
    `TEST_VALUE(0, $rtoi(r1_fcov.reg32_wr_cg.get_coverage()), "no coverage achieved");
    
    cpu_handle.enable_functional_coverage = 1;
    wr_data.field = 32'h0;
    regmodel.r1.write(cpu_handle, wr_data);
    `TEST_VALUE(50, $rtoi(r1_fcov.reg32_wr_cg.get_coverage()), "coverage false achieved");
    wr_data.field = 32'hdeadbeef;
    regmodel.r1.write(cpu_handle, wr_data);
    `TEST_VALUE(100, $rtoi(r1_fcov.reg32_wr_cg.get_coverage()), "coverage target achieved");
  endtask

  task test_r1_read_sample;
    regmodel.r1.attach(r1_fcov);
    cpu_handle.enable_functional_coverage = 1;
    wr_data.field = 32'h0;
    regmodel.r1.write(cpu_handle, wr_data);
    regmodel.r1.read(cpu_handle, rd_data);
    `TEST_VALUE(50, $rtoi(r1_fcov.reg32_rd_cg.get_coverage()), "read false coverage hit");
    
    wr_data.field = 32'hdeadbeef;
    regmodel.r1.write(cpu_handle, wr_data);
    regmodel.r1.read(cpu_handle, rd_data);
    `TEST_VALUE(32'hdeadbeef, rd_data, "Field data must match");
    `TEST_VALUE(100, $rtoi(r1_fcov.reg32_rd_cg.get_coverage()), "read all coverage hit");
  endtask

  task test_r1_field_read_sample;
    bit[31:0] field_data;
    regmodel.r1.attach(r2_fcov);
    cpu_handle.enable_functional_coverage = 1;
    wr_data.field = 32'h0;
    regmodel.r1.write(cpu_handle, wr_data);
    regmodel.r1.field.read(cpu_handle, field_data);
    `TEST_VALUE(32'h0, field_data, "Field data must match");
    `TEST_VALUE(50, $rtoi(r2_fcov.reg32_rd_cg.get_coverage()), "read false coverage hit");

    wr_data.field = 32'hdeadbeef;
    regmodel.r1.write(cpu_handle, wr_data);
    regmodel.r1.field.read(cpu_handle, field_data);
    `TEST_VALUE(32'hdeadbeef, field_data, "Field data must match");
    `TEST_VALUE(100, $rtoi(r2_fcov.reg32_rd_cg.get_coverage()), "read false coverage hit");
  endtask


  virtual task run();
    `RUN_TEST(test_attach_observer);
    `RUN_TEST(test_detach_observer);
    `RUN_TEST(test_detach_all);
    `RUN_TEST(test_r1_write_sample);
    `RUN_TEST(test_r1_read_sample);
    `RUN_TEST(test_r1_field_read_sample);
  endtask

endclass
`endif

