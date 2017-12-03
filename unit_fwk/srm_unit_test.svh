`define RUN_TEST(test) \
  do begin      \
    setup();    \
    local_fail_cnt = 0; \
    $write("UnitTestRun:%s:Line %0d:%s:", \
            `__FILE__, `__LINE__, `"test`"); \
    test();     \
    if(local_fail_cnt) $write("FAIL:%0d\n", local_fail_cnt); else $write("PASS\n"); \
    test_fail_cnt += local_fail_cnt; \
    test_pass_cnt += local_pass_cnt; \
    teardown(); \
  end while(0)

`define TEST_VALUE(a, b, msg) \
 do begin                     \
   if((a) == (b)) begin       \
     pass_cnt += 1;           \
     local_pass_cnt += 1;     \
  end else begin              \
     fail_cnt += 1;           \
     local_fail_cnt += 1;     \
     $display("TestFailed:%s:Expected:%0d(0x%0x), Got %0d(0x%0x)", msg, a, a, b, b); \
  end                         \
 end while(0)

`define TEST_STRING(a, b, msg) \
 do begin                     \
   if((a) == (b)) begin       \
     pass_cnt += 1;           \
     local_pass_cnt += 1;     \
  end else begin              \
     fail_cnt += 1;           \
     local_fail_cnt += 1;     \
     $display("TestFailed:%s:Expected:%s, Got %s", msg, a, b); \
  end                         \
 end while(0)

`define TEST_HANDLE(a, b, msg) \
 do begin                     \
   if((a) == (b)) begin       \
     pass_cnt += 1;           \
     local_pass_cnt += 1;     \
  end else begin              \
     fail_cnt += 1;           \
     local_fail_cnt += 1;     \
     $display("TestFailed:%s:Handle Expected:%p, Got %p", msg, a, b); \
  end                         \
 end while(0)

class srm_unit_test;
  string name;
  static int pass_cnt;
  static int fail_cnt;
  int logfile;
  int test_pass_cnt;
  int test_fail_cnt;
  int local_pass_cnt;
  int local_fail_cnt;
  
  static srm_unit_test test_list[string];

  function new(string name);
    this.name = name;
    srm_unit_test::test_list[name] = this;
  endfunction

  function string get_name();
    return name;
  endfunction

  virtual function void setup();
  endfunction

  virtual function void teardown();
  endfunction

  function void test_equal(bit expr, string failure_message = "");
    if(expr) begin
      pass_cnt += 1;
      test_pass_cnt += 1;
      local_pass_cnt += 1;
    end else begin
      fail_cnt += 1;
      test_fail_cnt += 1;
      local_fail_cnt += 1;
      $display("TestFailed:%s", failure_message);
    end
  endfunction

  function void summary(string name);
    $display("==============================================");
    if(test_fail_cnt == 0) begin
      $display("  UNIT_TEST_PASS:%s:PassCnt=%0d,FailCnt=%0d", 
                                        name, test_pass_cnt, test_fail_cnt);
    end
    else begin
      $display("  UNIT_TEST_FAIL:%s:PassCnt=%0d,FailCnt=%0d", 
                                        name, test_pass_cnt, test_fail_cnt);
    end
    $display("==============================================");
    $display("\n\n"); 
    
  endfunction

  virtual task run();
    assert(!"Derived class must override this");
  endtask

endclass

