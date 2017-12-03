//
// --------------------------------------------------------------
// Copyright (c) 2017-2023, Juniper Networks, Inc.
// All rights reserved.
//
// This code is licensed to you under the MIT license. 
// You many not use this code except in compliance with this license.
// This code is not an official Juniper product. You may obtain a copy
// of the license at 
//
// https://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is  distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR  CONDITIONS OF ANY KIND, either express or 
// implied.  See the License for the specific language governing
// permissions and limitations under the License.
// -------------------------------------------------------------
//
`ifndef INCLUDED_srm_utils_svh
`define INCLUDED_srm_utils_svh

//-----------------------------------------------------------------
// CLASS: srm_utils
// Utilities used my core classes.
//
// Static methods for easy bit manipulations.
//
//-----------------------------------------------------------------
class srm_utils;
  static function int floor(int value, int base);
    return value/base;
  endfunction

  static function int ceiling(int value, int base);
    int temp =  value / base;
    return (value % base) ? temp + 1 : temp;
  endfunction

  static function bit[7:0] create_byte_mask(bit[7:0] b, int start_idx, int len);
    bit[7:0] mask = 0;
    for(int i = 0; i < len; i++) mask |= (1 << i);
    mask <<= start_idx;
    return b & ~mask;
  endfunction

  // Get number of bits left over in a byte.
  static function int get_left_bits(int start_idx, int n_bits);
    int l = 8 - start_idx;
    return (n_bits > l) ? l : n_bits; 
  endfunction

  // Get number of bytes that would be required to store the field.
  static function int get_num_bytes(int lsb_pos, int n_bits);
    // Compute the number of bits valid in first byte
    int start_idx = lsb_pos % 8;
    int start_len = get_left_bits(.start_idx(start_idx), .n_bits(n_bits)); 

    // Remaning bits in second...last byte.
    n_bits -= start_len;
    return 1 + (srm_utils::ceiling(n_bits, 8));
  endfunction

  // Extract the slice and convert to a byte.
  static function bit[7:0] extract_byte_from(bit[7:0] d, int lsb);
    bit[7:0] mask;
    mask = 1 << (8 - lsb);
    return (d >> lsb) & (mask - 1);
  endfunction

  // Function: extract_field
  // 
  // Extracts the field bytes from the register bytes starting at lsb 
  // with given bits.
  //
  static function srm_data_t extract_field(const ref srm_data_t bytes, 
                                               input int lsb_pos, input int n_bits);
    srm_data_t field_bytes;
    int field_len_bytes, byte_offset, bits_valid, field_offset;
    int start_idx, num_bits_valid, shift_amt, start_offset;
    bit[7:0] rem_byte, result; 

    field_len_bytes = srm_utils::ceiling(n_bits, 8);
    byte_offset = srm_utils::floor(lsb_pos, 8);
    field_bytes = new[field_len_bytes];
    field_offset = 0;
    start_idx = lsb_pos % 8;

    if((start_idx + n_bits) <= 8) begin
      // Case 1: No remainder since field fits in 1 byte.
        field_bytes[0] = bytes[byte_offset] >> start_idx & ((1 << n_bits) -1);

    end else if(start_idx == 0 || ((lsb_pos + n_bits) <= 8)) begin
      // Case 2: No remainder bits since field is byte aligned.
      for(int i = 0; i < field_len_bytes; i++) begin
        bits_valid = (n_bits <= 8) ? n_bits : 8;
        field_bytes[i] = bytes[byte_offset] & ((1 << bits_valid) -1);
        byte_offset += 1;
        n_bits -= 8;
      end

    end else begin
      // Case 3: Remainder bits.
      rem_byte = srm_utils::extract_byte_from(.d(bytes[byte_offset]), 
                                              .lsb(start_idx));
      byte_offset += 1;
      shift_amt = 8 - start_idx;
      for(int i = 0; i < field_len_bytes; i++) begin
        result = (bytes[byte_offset] << shift_amt) | rem_byte;
        bits_valid = (n_bits < 8) ? n_bits : 8;
        field_bytes[i] = result & ((1 << bits_valid) - 1);
       
        // Get the remaining bits in a byte for the next round.
        rem_byte = srm_utils::extract_byte_from(.d(bytes[byte_offset]), 
                                              .lsb(start_idx));

        byte_offset += 1;
        n_bits -= 8;
      end
    end


    return field_bytes;
  endfunction

  // Function: merge_field
  //
  // Copy the field bytes into the correct position in the output register bytes.
  // The field can start at any bit position in the output register bytes and
  // can end of any bit position.
  // Care is taken so that only field bits are affected in the output register.
  // 
  static function void merge_field(ref srm_data_t reg_bytes, const ref srm_data_t field_bytes,
                                   input int lsb_pos, input int n_bits);
    int start_idx, start_len;
    int field_start_byte_offset, offset;
    bit[7:0] mdata, rem_byte, rem_mask, last_byte;
    int field_len_bytes, bits_valid;

    start_idx = lsb_pos % 8;
    start_len = srm_utils::get_left_bits(.start_idx(start_idx), .n_bits(n_bits));
    field_start_byte_offset = srm_utils::floor(lsb_pos, 8);
    field_len_bytes = srm_utils::get_num_bytes(.lsb_pos(lsb_pos), .n_bits(n_bits));

    if((start_idx + n_bits) <= 8) begin
      // Degenerate case when the field fits within 1 byte. No remainder.
      mdata = srm_utils::create_byte_mask(reg_bytes[field_start_byte_offset], 
                                          start_idx, start_len);
      reg_bytes[field_start_byte_offset] = mdata | (field_bytes[0] << start_idx);

    end else if(start_idx == 0) begin
      // Field starts aligned on byte boundary. No Remainder.
      // It can end on any bit boundary and so care is taken to mask the last byte.
      for(int i = 0; i < field_len_bytes; i++) begin
        bits_valid = (n_bits <= 8) ? n_bits : 8;
        reg_bytes[field_start_byte_offset + i] = field_bytes[i] & ((1<<bits_valid) -1);
        n_bits -= 8;
      end
    end

    else begin
      // First byte. Extract the remainder and shift the field by start index.
      rem_byte = srm_utils::extract_byte_from(.d(field_bytes[0]), .lsb(8-start_idx));
      mdata = srm_utils::create_byte_mask(reg_bytes[field_start_byte_offset], 
                                          start_idx, start_len);
      reg_bytes[field_start_byte_offset] = mdata | (field_bytes[0] << start_idx);
      n_bits -= start_len;
      offset = 1; // Done with field_bytes[0]

      // Middle bytes. Ends on a byte boundary so no masking is required.
      for(int i = 1; i < (field_len_bytes-1); i++) begin
        reg_bytes[field_start_byte_offset + i] = (field_bytes[offset] << start_idx) | rem_byte;
        rem_byte = srm_utils::extract_byte_from(.d(field_bytes[offset]), .lsb(8-start_idx));
        n_bits -= 8;
        offset += 1;
      end

      // Last byte.
      if(n_bits > 0) begin
        // Last byte always starts from bit 0 and has msb at n_bits -1.
        last_byte = (field_bytes[offset] << start_idx) | rem_byte;
        last_byte &= (1<<n_bits) -1;
        mdata = srm_utils::create_byte_mask(reg_bytes[field_start_byte_offset + field_len_bytes -1], 
                                          0, n_bits);
        reg_bytes[field_start_byte_offset + field_len_bytes -1] = (mdata | last_byte);
      end
    end

  endfunction

  // Function: extract_field_enables
  //
  // Get the byte enables for the bytes in the field.
  //
  static function srm_byte_enable_t extract_field_enables(const ref srm_byte_enable_t byte_enables, 
                                               input int lsb_pos, input int n_bits);
    int num_bytes = get_num_bytes(lsb_pos, n_bits);
    int field_start_byte_offset = srm_utils::floor(lsb_pos, 8);
    srm_byte_enable_t field_enables = new[num_bytes];
  
    for(int i = 0; i < num_bytes; i++) begin
      field_enables[i] = byte_enables[field_start_byte_offset + i];
    end
    
    return field_enables;
  endfunction
 
  // Function: set_field_enables
  //
  // Set the byte enables for the bytes in the field.
  //
  static function void set_field_enables(ref srm_byte_enable_t byte_enables, 
                                               input int lsb_pos, input int n_bits);
    int num_bytes = get_num_bytes(lsb_pos, n_bits);
    int field_start_byte_offset = srm_utils::floor(lsb_pos, 8);
  
    for(int i = 0; i < num_bytes; i++) begin
      byte_enables[field_start_byte_offset + i] = 1;
    end
    
  endfunction
 
  // Function: bytes_2_hex
  //
  // Convert a list of bytes into a hex string.
  // A debug function.
  //
  static function string bytes_2_hex(const ref srm_data_t bytes);
    string name;
    string hex = "0x";
    for(int i = bytes.size()-1; i >= 0; i--) begin
      hex = {hex, $psprintf("%x", bytes[i])};
    end
    return hex;
  endfunction

  static function string bits_2_str(const ref srm_byte_enable_t bits);
    string name;
    string pattern = "";
    for(int i = bits.size()-1; i >= 0; i--) begin
      pattern = {pattern, $psprintf("%b", bits[i])};
    end
    return pattern;
  endfunction

  static function bit is_same_bytes(const ref srm_data_t bytes1, 
                                    const ref srm_data_t bytes2);
    if(bytes1.size() != bytes2.size()) return 0;
    foreach(bytes1[i]) begin
      if(bytes1[i] != bytes2[i]) return 0;
    end
    return 1;
  endfunction

endclass

`endif
