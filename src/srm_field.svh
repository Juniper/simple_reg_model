`ifndef INCLUDED_srm_field_svh
`define INCLUDED_srm_field_svh

typedef class srm_handle;
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
  local int _reset_kind[string];

  //---------------------------
  // Group: Initialization
  //---------------------------
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
    _is_initialized = 1;
  endfunction

  // Function: get
  // Get the value of the field.
  // If the field has not been written and has reset then return the last reset kind value.
  // If not resettable then reading before writing is a fatal error.
  virtual function T get();
    T dummy;
    if(_is_initialized) begin
      return _entry;
    end else if(_parent.is_reset_present()) begin
      string last_reset_kind = _parent.get_last_reset_kind();
      return _reset_values[last_reset_kind];
    end
    else begin
      `uvm_error("ReadBeforeWrite", 
        $sformatf("Uninitialized field \"%s\" that is not resettable.", get_full_name()));
      return dummy;
    end
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
  virtual task write(srm_handle handle, T data);
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

    // For updating the model we don't worry about byte enables since this is a rmw.
    p.set_bytes(reg_bytes);
  endtask

  // Task: read
  // Read the contents of the field.
  //
  // A read to the parent register is issued with the correct byte enables.
  // The field data is them stripped and compared to the model data.
  virtual task read(srm_handle handle);
  endtask

  //-------------------------------------
  // Group: Reset
  //-------------------------------------

  // Function: set_reset_value
  //
  // Sets the reset value of the field under different kinds of reset.
  virtual function void set_reset_value(T value, input string kind);
    _reset_kind[kind] = 1;
    _reset_values[kind] = value;
  endfunction

  // Function: get_reset_value
  //
  // Get the reset value of the field under different kinds of reset.
  //
  virtual function T get_reset_value(string kind);
    return _reset_values[kind];
  endfunction
  


endclass

`endif
