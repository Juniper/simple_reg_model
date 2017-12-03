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
`ifndef INCLUDED_srm_field_svh
`define INCLUDED_srm_field_svh

typedef class srm_base_handle;
//---------------------------------------------------
// CLASS: srm_field
// Template class to model the fields in a register.
//
// A field has 'n' bits, multiple reset values and an access
// policy. 
//---------------------------------------------------
class srm_field#(type T = int) extends srm_base_field;

  local T _entry;
  local T _reset_values[string];

  //---------------------------
  // Group: Initialization
  //---------------------------
  
  // Function: new
  //
  // Create a new instance of a field.
  //
  // ~name~ is the name of the field.
  // ~parent~ is the pointer to the register to which the field belongs.
  // ~nbits~ is the size of the field in bits.
  // ~lsb_pos~ is the least significant position 
  //
  function new(string name, srm_base_reg parent, int n_bits, int lsb_pos,
               bit volatile);
    super.new(name, parent, n_bits, lsb_pos, volatile);
  endfunction

  //-------------------------------------
  // Group: Converter 
  //-------------------------------------

  // Function: data_2_bytes
  //
  // Converts the template data type into a list of bytes.
  //
  // Format is
  // {byte_n, byte_n_1, ..., byte_1, byte_0} = [msb..lsb]
  // Note that the lsb of field corresponds to lsb of byte0.
  //
  virtual function srm_data_t data_2_bytes(const ref T data);
    srm_data_t bytes;
    int num_bytes;
    bit [$bits(T)-1:0] datax;
   
    // Fields may not be byte aligned.
    num_bytes = srm_utils::ceiling($bits(T), 8);
    bytes = new[num_bytes];
    
    datax = data;
    // [msb...lsb] = {byte_n, byte_n_1, ..., byte_1, byte_0}
    for(int i = 0; i < num_bytes; i++) begin
      bytes[i] = (datax >> (i*8)) & 'hff;
    end
   
    return bytes;
  endfunction

  //
  // Function: bytes_2_data
  // 
  // Converts the list of bytes into template data type.
  //
  // Format is
  // [msb...lsb] = {byte_n, byte_n_1, ..., byte_1, byte_0}
  // Note that the lsb of byte 0 corresponds to lsb of the field.
  //
  virtual function T bytes_2_data(const ref srm_data_t bytes);
    bit [$bits(T)-1:0] datax;
    T data;
    int shift_bits, num_shifted, total_bits;

    num_shifted = 0;
    total_bits = $bits(T);
    datax = 'h0;
    shift_bits = 'h0;

    for(int i = bytes.size() - 1; i >= 0; i--) begin
      datax <<= shift_bits;
      datax |= bytes[i];
      shift_bits = total_bits - num_shifted;
      if(shift_bits > 8) shift_bits = 8;
      num_shifted += shift_bits;
    end

    data = datax;
    return data;
  endfunction

  //-------------------------------------
  // Group: Model Access 
  //-------------------------------------

  // Function: set
  //
  // Sets the value of the field in the model.
  //
  virtual function void set(T data);
    _entry = data;
  endfunction

  // Function: get
  //
  // Get the value of the field.
  //
  virtual function T get();
    return _entry;
  endfunction

  // Function: get_bytes
  //
  // Get the model value as a list of bytes.
  //
  virtual function srm_data_t get_bytes();
    T data = get();
    return data_2_bytes(data);
  endfunction

  // Function: set_bytes
  //
  // Set the value of the model by a list of bytes.
  //
  virtual function void set_bytes(const ref srm_data_t bytes);
    T data = bytes_2_data(bytes);
    set(data);
  endfunction

  //------------------
  // Group: Model+Design Access 
  //-------------------

  // Task: write
  // Write the field in the design and model.
  //
  // Generate write with correct byte enable set for the field. Also
  // other field values are set to the value from the model.
  // It is possible to make data as const ref but then I cannot pass 
  // literal constants. 
  //
  virtual task write(srm_base_handle handle, T data);
    srm_base_field_policy policy;
    int allow_update;
    srm_data_t field_bytes, reg_bytes;
    srm_byte_enable_t byte_enables;
    srm_base_reg p;

    field_bytes = data_2_bytes(data);

    p= get_parent();
    reg_bytes = p.get_bytes();
    srm_utils::merge_field(.reg_bytes(reg_bytes), .field_bytes(field_bytes),
                           .lsb_pos(get_lsb_pos()), .n_bits(get_n_bits()));

    byte_enables = new[p.get_width_bytes()];
    for(int i = 0; i < p.get_width_bytes(); i++) byte_enables[i] = 0;
    srm_utils::set_field_enables(byte_enables, .lsb_pos(get_lsb_pos()),
                                 .n_bits(get_n_bits()));

    p.__write_bytes(.handle(handle), .bytes(reg_bytes), 
                                                .byte_enables(byte_enables));

    policy = get_policy(handle.addr_map_name);
    allow_update = policy.write_policy(this, field_bytes);
    if(allow_update) begin
      set_bytes(field_bytes);
    end
  endtask

  // Task: read
  // Read the contents of the field.
  //
  // A read to the parent register is issued with the correct byte enables.
  // The field data is them stripped and compared to the model data.
  //
  virtual task read(srm_base_handle handle, output T data);
    srm_base_field_policy policy;
    int allow_update;
    srm_byte_enable_t byte_enables;
    srm_base_reg p;
    srm_data_t reg_bytes, field_bytes;
    
    p= get_parent();
    
    reg_bytes = new[p.get_width_bytes()];
    byte_enables = new[p.get_width_bytes()];
    for(int i = 0; i < p.get_width_bytes(); i++) byte_enables[i] = 0;
    srm_utils::set_field_enables(byte_enables, .lsb_pos(get_lsb_pos()),
                                 .n_bits(get_n_bits()));

    p.__read_bytes(.handle(handle), .bytes(reg_bytes), .byte_enables(byte_enables),
                   .skip_check(0));

    field_bytes = srm_utils::extract_field(.bytes(reg_bytes), .lsb_pos(_lsb_pos),
                                           .n_bits(_n_bits));
    
    data = bytes_2_data(field_bytes); // Return the data from design to the caller.

    // Volatile fields needs to be updated. Sometimes the fields have side affect of doing a read.
    // For example "ReadSet" causes the read to set all the bits of the field. This type of behavior
    // is treated as read followed by an embedded write that sets the bits.

    policy = get_policy(handle.addr_map_name);
    allow_update = policy.read_policy(this, field_bytes);
    if(allow_update) begin
      set_bytes(field_bytes);
    end

    if(handle.enable_functional_coverage) begin
      p.post_read();
    end

  endtask

  //-------------------------------------
  // Group: Reset
  //-------------------------------------

  // Function: set_reset_value
  //
  // Sets the reset value of the field under different kinds of reset.
  //
  // ~value~ is the reset value.
  // ~kind~ is the type of reset. For example hard, bist, soft etc.
  //
  virtual function void set_reset_value(T value, input string kind);
    _reset_values[kind] = value;
  endfunction

  // Function: get_reset_value
  //
  // Get the reset value of the field under different kinds of reset.
  //
  // ~kind~ is the type of reset. For example hard, bist, soft etc.
  //
  virtual function T get_reset_value(string kind);
    return _reset_values[kind];
  endfunction
  
  // Function: reset
  //
  // Reset the field with the specified reset.
  //
  // ~kind~ is the type of reset. For example hard, bist, soft etc.
  // Updates the field data with the reset value.
  //
  virtual function void reset(string kind);
    _entry = get_reset_value(kind);
  endfunction


  //-------------------------------------
  // Group: Private
  //-------------------------------------
  // Function: __initialize
  //
  // Initialize the state from the current value.
  //
  // Used by the framework to clone array register entries.
  //
  virtual function void __initialize(srm_base_field obj);
    srm_field#(T) field;
    super.__initialize(obj);
    $cast(field, obj);
    _entry = field._entry;
    _reset_values = field._reset_values;
  endfunction

endclass

`endif
