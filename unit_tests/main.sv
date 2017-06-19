module main;
  string unit_test_name;
  srm_unit_test test;

  test_reg32 t1 = new();
  test_table32 t2 = new();
  test_top t3 = new();
  test_default_offset t4 = new();
  test_field_access t5 = new();
  test_reg_reset t6 = new();
  test_table_reset t7 = new();
  test_reg_rw t8 = new();
  test_table_rw t9 = new();
  test_srm_utils_1 t10 = new();
  test_srm_utils_2 t11 = new();
  test_volatile_field t12 = new();
  test_field_rw t13 = new();

  initial begin
    if($value$plusargs("UNIT_TEST_NAME=%s", unit_test_name)) begin
      $display("Running %s test(s)", unit_test_name);
    end

    if(unit_test_name == "all") begin
      foreach(srm_unit_test::test_list[i]) begin
        $display("Run Test %s", srm_unit_test::test_list[i].get_name());
        srm_unit_test::test_list[i].run();
      end
    end
    else begin
      test = srm_unit_test::test_list[unit_test_name];
      if(test == null) begin
        $display("Could not find test %s", unit_test_name);
   
       foreach(srm_unit_test::test_list[i]) begin
          $display("Dump: TestName %s", srm_unit_test::test_list[i].get_name());
        end

        $fatal(-1);
      end
      $display("Run Test %s", test.get_name());
      test.run();
    end

    if(srm_unit_test::fail_cnt == 0) begin
      $display("SRUN_TEST_PASS:PassCnt=%0d", srm_unit_test::pass_cnt);
    end else begin
      $display("SRUN_TEST_FAIL:PassCnt=%0d,FailCnt=%0d", 
                              srm_unit_test::pass_cnt, srm_unit_test::fail_cnt);
    end
  end
endmodule
