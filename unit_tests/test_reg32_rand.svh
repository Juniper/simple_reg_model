`ifndef INCLUDED_test_reg32_rand_sv
`define INCLUDED_test_reg32_rand_sv


class test_reg32_rand extends srm_unit_test;

  cpu_reg32 regmodel;

  cpu_reg32::r1_struct_t wr_data, rd_data;

  function new();
    super.new("test_reg32_rand");
  endfunction

  virtual function void setup();
    regmodel = new(.name("regmodel"), .parent(null));
    regmodel.set_offset(.addr_map_name("cpu_map"), .offset(64'h10000));

  endfunction

  task test_set_get_r1;
    cpu_reg32::r1_constr c1;
    c1 = cpu_reg32::r1_constr::type_id::create("r1_constr");
    assert(c1.randomize());
    wr_data = c1.get_data();

    regmodel.r1.set(wr_data);
    rd_data = regmodel.r1.get();
    `TEST_VALUE(wr_data.field, rd_data.field, "get data matches the set data"); 
  endtask

  virtual task run();
    `RUN_TEST(test_set_get_r1);
  endtask

endclass
`endif
