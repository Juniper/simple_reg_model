`ifndef INCLUDED_test_srm_utils_1_sv
`define INCLUDED_test_srm_utils_1_sv


class test_srm_utils_1 extends srm_unit_test;

  function new();
    super.new("test_srm_utils_1");
  endfunction

  task test_byte_mask;
    `TEST_VALUE(8'h0, srm_utils::create_byte_mask(8'hff, 0, 8), "Mask the entire byte");
    `TEST_VALUE(8'h1, srm_utils::create_byte_mask(8'hff, 1, 7), "Mask the entire byte");
    `TEST_VALUE(8'hf, srm_utils::create_byte_mask(8'hff, 4, 4), "Mask the entire byte");
    `TEST_VALUE(8'he7, srm_utils::create_byte_mask(8'hff, 3, 2), "Mask the entire byte");
    `TEST_VALUE(8'hc1, srm_utils::create_byte_mask(8'hff, 1, 5), "Mask the entire byte");
  endtask

  task test_get_num_bits;
    `TEST_VALUE(3, srm_utils::get_left_bits(.start_idx(4), .n_bits(3)), "start_idx=4, len=3");
    `TEST_VALUE(8, srm_utils::get_left_bits(.start_idx(0), .n_bits(9)), "start_idx=0, len=9");
    `TEST_VALUE(4, srm_utils::get_left_bits(.start_idx(4), .n_bits(7)), "start_idx=4, len=7");
    `TEST_VALUE(1, srm_utils::get_left_bits(.start_idx(7), .n_bits(8)), "start_idx=7, len=8");
  endtask

  task test_get_num_bytes;
    `TEST_VALUE(4, srm_utils::get_num_bytes(.lsb_pos(17), .n_bits(31)), "lsb=17, len=31");
    `TEST_VALUE(1, srm_utils::get_num_bytes(.lsb_pos(12), .n_bits(2)), "lsb=12, len=2");
    `TEST_VALUE(4, srm_utils::get_num_bytes(.lsb_pos(1), .n_bits(24)), "lsb=1, len=24");
  endtask

  task test_extract_byte;
    `TEST_VALUE(8'ha5, srm_utils::extract_byte_from(8'ha5, .lsb(0)), 
                                                 "zero lsb is no change");
    `TEST_VALUE(8'ha, srm_utils::extract_byte_from(8'ha5, .lsb(4)), 
                                                 "extract uppper nibble");
    `TEST_VALUE(8'h2, srm_utils::extract_byte_from(8'ha5, .lsb(6)), 
                                                 "extract upper 2 bits");
    `TEST_VALUE(8'h1, srm_utils::extract_byte_from(8'ha5, .lsb(7)), 
                                                  "extract from lsb");
  endtask

  task test_bytes_2_hex_1;
    srm_data_t bytes = {8'h5};
    `TEST_STRING("0x05", srm_utils::bytes_2_hex(bytes), "Single byte display");
  endtask

  task test_bytes_2_hex_16;
    srm_data_t bytes;
    bytes = new[16];
    for(int i = 0; i < 16; i++) bytes[i] = i;
    `TEST_STRING("0x0f0e0d0c0b0a09080706050403020100", srm_utils::bytes_2_hex(bytes), "16 byte display");
  endtask

  task test_extract_byte_enables;
    srm_byte_enable_t field_enables;
    srm_byte_enable_t byte_enables;
    byte_enables = new[4];

    for(int i = 0; i < 4; i++) byte_enables[i] = 1;
    field_enables = srm_utils::extract_field_enables(byte_enables, 12, 5);
    `TEST_VALUE(2, field_enables.size(), "size of field enables 12:16 match");
    `TEST_STRING("11", srm_utils::bits_2_str(field_enables), "Byte enables must match");
  endtask

  task test_set_byte_enables;
    srm_byte_enable_t byte_enables;
    byte_enables = new[3];
    for(int i = 0; i < 3; i++) byte_enables[i] = 0;
    srm_utils::set_field_enables(byte_enables, 12, 4);
    `TEST_STRING("010", srm_utils::bits_2_str(byte_enables), "set bit 12:15 match");
    srm_utils::set_field_enables(byte_enables, 20, 4);
    `TEST_STRING("110", srm_utils::bits_2_str(byte_enables), "set bit 20:23 match");
    srm_utils::set_field_enables(byte_enables, 1, 1);
    `TEST_STRING("111", srm_utils::bits_2_str(byte_enables), "set bit 1 match");
  endtask

  task test_set_byte_enables_2;
    srm_byte_enable_t byte_enables;
    byte_enables = new[4];
    for(int i = 0; i < 3; i++) byte_enables[i] = 0;
    srm_utils::set_field_enables(byte_enables, 8, 1);
    `TEST_STRING("0010", srm_utils::bits_2_str(byte_enables), "set bit byte1 match");
    srm_utils::set_field_enables(byte_enables, 23, 2);
    `TEST_STRING("1110", srm_utils::bits_2_str(byte_enables), "set bit byte2-3 match");
  endtask

  virtual task run();
    `RUN_TEST(test_byte_mask);
    `RUN_TEST(test_get_num_bits);
    `RUN_TEST(test_get_num_bytes);
    `RUN_TEST(test_extract_byte);
    `RUN_TEST(test_bytes_2_hex_1);
    `RUN_TEST(test_bytes_2_hex_16);
    `RUN_TEST(test_extract_byte_enables);
    `RUN_TEST(test_set_byte_enables);
    `RUN_TEST(test_set_byte_enables_2);
  endtask
endclass

`endif
