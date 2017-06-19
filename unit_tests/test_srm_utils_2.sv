`ifndef INCLUDED_test_srm_utils_2_sv
`define INCLUDED_test_srm_utils_2_sv

import srm_pkg::*;
class test_srm_utils_2 extends srm_unit_test;
  function bit[31:0] bytes_2_bits(srm_data_t bytes);
    reg[31:0] out_bits;
    for(int i = 0; i < 32/8; i++) begin
      for(int j = 0; j < 8; j++) begin
        out_bits[i*8 + j] = bytes[i] >> j;
      end
    end
    return out_bits;
  endfunction

  function srm_data_t bits_2_bytes(bit[31:0] d);
    bit[7:0] temp;
    srm_data_t bytes = new[4];
    for(int i = 0; i < 4; i++) begin
      bytes[i] = 0;
      temp = 'h0;
      for(int j = 8; j > 0; j--) begin
        temp = temp << 1;
        temp |= d[i*8+j-1];
      end
      bytes[i] = temp;
    end
    return bytes;
  endfunction
  
  function new();
    super.new("test_srm_utils_2");
  endfunction

  task test_bytes_2_bits;
    bit[31:0] bits;
    srm_data_t bytes = new[4];
    for(int i = 0; i < 4; i++) bytes[i] = i;
    bits = bytes_2_bits(bytes);
    `TEST_VALUE(32'h03020100, bits, "Bits must match byte3-0");
  endtask

  task test_bits_2_bytes;
    bit[31:0] bits;
    srm_data_t bytes;
    bits = 32'hdeadbeef;
    bytes = bits_2_bytes(bits);

    `TEST_VALUE(8'hef, bytes[0], "byte 0 must match");
    `TEST_VALUE(8'hbe, bytes[1], "byte 1 must match");
    `TEST_VALUE(8'had, bytes[2], "byte 2 must match");
    `TEST_VALUE(8'hde, bytes[3], "byte 3 must match");
  endtask

  task test_byte_merge;
    srm_data_t in_bytes, out_bytes, exp_bytes, fbytes;
    bit[31:0] bits;
    int lsb_pos;
    fbytes = new[1];
    lsb_pos = 0;

    while(lsb_pos != 7) begin
      for(int n_bits = 1; (n_bits + lsb_pos) < 8; n_bits++) begin
        fbytes[0] = 'h0;
        bits = 32'hffffffff;
        in_bytes = bits_2_bytes(bits);

        for(int offset = 0; offset < 4; offset++) begin
          for(int i = lsb_pos; i < (lsb_pos + n_bits); i++) begin
            bits[offset*8+i] = fbytes[i-lsb_pos];
          end
          exp_bytes = bits_2_bytes(bits);
          srm_utils::merge_field(.reg_bytes(in_bytes), 
                                    .field_bytes(fbytes),
                                    .lsb_pos(offset*8+lsb_pos), .n_bits(n_bits));
          `TEST_VALUE(exp_bytes[offset], in_bytes[offset], 
                         $psprintf("Offset=%0d,LsbPos=%0d,n_bits=%0d", offset,lsb_pos, n_bits));
        end
      end
      lsb_pos += 1;
    end

  endtask

  virtual task run();
    `RUN_TEST(test_bytes_2_bits);
    `RUN_TEST(test_bits_2_bytes);
//FIXME    `RUN_TEST(test_byte_merge);
  endtask
endclass

`endif
