`ifndef INCLUDED_srm_base_reg_svh
`define INCLUDED_srm_base_reg_svh

typedef class srm_base_field;
//--------------------------------------------------------
// CLASS: srm_base_reg
// Abstract register base model:
//
// Register without the template data. This allows the base 
// field to access the contents of the register and updates 
// coming from the monitor to update the value.
//--------------------------------------------------------
virtual class srm_base_reg extends srm_component;
  protected srm_base_field _fields[$];
  protected int _reset_kind[string];
  
  //------------------
  // Group: Initialization
  //-------------------
  
  // Function: new
  function new(string name, srm_component parent);
    super.new(name, parent);
  endfunction

  // Function: add_field
  //
  function void add_field(srm_base_field f);
    _fields.push_back(f);
  endfunction

  // Function: set_policy
  // Sets the policy on all the field nodes.
  //
  virtual function void set_policy(string addr_map_name, srm_base_policy policy);
    foreach(_fields[i]) begin
      _fields[i].set_policy(addr_map_name, policy);
    end
  endfunction

  //------------------
  // Group: Introspection
  //-------------------
  // Function: get_width_bytes
  // Returns the width of the register in bytes
  //
  virtual function int get_width_bytes();
    int num_bits = 0;
    foreach(_fields[i]) num_bits += _fields[i].get_n_bits();
    assert( num_bits % 8 == 0); // Must be byte aligned.
    return num_bits/8;
  endfunction

  // Function: get_size
  // Return the number of bytes in address map.
  //
  virtual function srm_addr_t get_size(string addr_map_name);
    if(!_size_table.exists(addr_map_name)) 
      _size_table[addr_map_name] = get_width_bytes();
    return _size_table[addr_map_name];
  endfunction

  // Function: get_num_fields
  // Return the number of fields in the entry.
  //
  virtual function int get_num_fields();
    return _fields.size();
  endfunction

  // Function: get_index
  // This is for callback to access the index of the array entry.
  virtual function srm_addr_t get_index();
    return 0;
  endfunction
 
  //------------------
  // Group: Reset
  //-------------------
 
  // Function: set_reset_kind
  // Set the type of reset supported on the register.
  // The model needs to ensure same kind supported by all the fields
  // in the register.
  virtual function void set_reset_kind(string kind);
    _reset_kind[kind] = 1;
  endfunction

  // Function: is_resettable
  virtual function bit is_resettable(string kind);
    return _reset_kind.exists(kind);
  endfunction

  // Function: is_reset_present
  // Check if register has reset.
  virtual function bit is_reset_present();
    return _reset_kind.size() > 0;
  endfunction

  // Function: reset
  // If resettable, reset all the fields of the register.
  virtual function void reset(string kind);
    if(is_resettable(kind)) begin
      foreach(_fields[i]) _fields[i].reset(kind);
    end
  endfunction


  //------------------
  // Group: Model Access 
  //-------------------
  
  // Function: get_bytes
  // Get the value of the register model as a list of bytes.
  //
  // Get the value from the constituent fields and merge them together.
  virtual function srm_data_t get_bytes();
    srm_data_t field_bytes, reg_bytes;
    int num_bytes = get_width_bytes();

    reg_bytes = new[num_bytes];
    for(int i = 0; i < num_bytes; i++) reg_bytes[i] = 'h0; //Clear for merge later
    foreach(_fields[i]) begin
      field_bytes = _fields[i].get_bytes();
      srm_utils::merge_field(.reg_bytes(reg_bytes), .field_bytes(field_bytes),
        .lsb_pos(_fields[i].get_lsb_pos()), .n_bits(_fields[i].get_n_bits()));
    end
    return reg_bytes;
  endfunction

  // Function: set_bytes
  // Set the value of the register model.
  //
  // Extract the field values and set them.
  virtual function void set_bytes(const ref srm_data_t bytes);
    srm_data_t field_bytes;

    foreach(_fields[i]) begin
      field_bytes = srm_utils::extract_field(.bytes(bytes), .lsb_pos(_fields[i].get_lsb_pos()),
                    .n_bits(_fields[i].get_n_bits()));
      _fields[i].set_bytes(field_bytes);
    end
  endfunction

  //------------------
  // Group: Model+Design Access 
  //-------------------
  
  // Task: load
  // Load the design data into the model.
  //
  // No checking is done and the model is silently updated.
  virtual task load(srm_base_handle handle);
    srm_data_t bytes;
    srm_byte_enable_t byte_enables;
    int num_bytes = get_width_bytes(); 

    bytes = new[num_bytes];
    byte_enables = new[num_bytes];
    for(int i = 0; i < num_bytes; i++) byte_enables[i] = 1;

    __read_bytes(handle, bytes, byte_enables, .skip_check(1));

    set_bytes(bytes);
    
  endtask

  // Task: store
  // Store the model data into the design.
  //
  virtual task store(srm_base_handle handle);
    srm_data_t bytes;
    srm_byte_enable_t byte_enables;
    int num_bytes = get_width_bytes(); 

    bytes = get_bytes();
    byte_enables = new[num_bytes];
    for(int i = 0; i < num_bytes; i++) byte_enables[i] = 1;
  
    __write_bytes(handle, bytes, byte_enables);

  endtask

  //----------------------
  // Group: Functional Coverage
  //----------------------

  // Function: attach
  // Attach an observer to itself.
  //
  virtual function void attach(srm_base_coverage observer);
    _coverage_cbs.push_back(observer);
  endfunction

  // Function: detach
  // Detach an observer if it exists.
  //
  virtual function void detach(srm_base_coverage observer);
    foreach(_coverage_cbs[i]) begin
      if(_coverage_cbs[i] == observer) _coverage_cbs.delete(i);
    end
  endfunction

  // Function: detach_all
  // Detach all observers
  virtual function void detach_all();
    _coverage_cbs = {};
  endfunction

  // Function: post_write
  // Post write functional callbacks.
  virtual function void post_write();
    for(int i = 0; i < _coverage_cbs.size(); i++) begin
      _coverage_cbs[i].post_write(this);
    end
  endfunction

  // Function: post_read
  // Post read functional coverage.
  virtual function void post_read();
    for(int i = 0; i < _coverage_cbs.size(); i++) begin
      _coverage_cbs[i].post_read(this);
    end
  endfunction

  // Function: sample_xact
  // Generate xact functional covearage.
  virtual function void sample_xact(const ref srm_generic_xact_t generic_xact);
    for(int i = 0; i < _coverage_cbs.size(); i++) begin
      _coverage_cbs[i].sample_xact(generic_xact);
    end
  endfunction

  //------------------
  // Group: Private API
  //-------------------

  // Function: __initialize
  // Private function to create the clone.
  protected function void __initialize(srm_base_reg obj);
    foreach(obj._fields[i]) 
      obj._fields[i].__initialize(_fields[i]);
    obj._coverage_cbs = _coverage_cbs;
    obj._reset_kind = _reset_kind;
  endfunction

  // Function: __write_bytes
  // Send the bus xact to the adapter class. if no response from adapter then the
  // model value is updated at the end otherwise done later by the xact from monitor.
  //
  // For use by framework classes only.
  virtual task __write_bytes(srm_base_handle handle, const ref srm_data_t bytes, 
                       const ref srm_byte_enable_t byte_enables);
    srm_generic_xact_t generic_xact;
    srm_bus_adapter adapter;

    generic_xact.addr_map_name = handle.addr_map_name;
    generic_xact.kind = SRM_WRITE;
    generic_xact.addr = get_offset(handle.addr_map_name);
    generic_xact.data = bytes;
    generic_xact.byte_enables = byte_enables;

    // Launch the operation
    adapter = handle.adapter_policy.get_adapter(this);
    adapter.execute(generic_xact, handle.seq_priority);

    // Gather coverage if enabled.
    if(handle.enable_functional_coverage) begin
      sample_xact(generic_xact);
    end

    handle.generic_xact_status = generic_xact.status;

  endtask


  // Function: __read_bytes
  // Read the data from the register.
  //
  // Checks that the read data matches the model value. Will report
  // error for non volatile fields. Volatile fields are silently updated.
  virtual task __read_bytes(srm_base_handle handle, ref srm_data_t bytes,
                            const ref srm_byte_enable_t byte_enables,
                            input bit skip_check=0);
    srm_generic_xact_t generic_xact;
    srm_bus_adapter adapter;
    srm_byte_enable_t field_byte_enables;
    bit field_byte_enables_on;
    srm_data_t current_field_bytes, new_field_bytes;
    string msg;

    generic_xact.addr_map_name = handle.addr_map_name;
    generic_xact.kind = SRM_READ;
    generic_xact.addr = get_offset(handle.addr_map_name);
    generic_xact.data = bytes;
    generic_xact.byte_enables = byte_enables;

    // Launch the operation
    adapter = handle.adapter_policy.get_adapter(this);
    adapter.execute(generic_xact, handle.seq_priority);
    
    handle.generic_xact_status = generic_xact.status;

    // Wait for the read to complete and data to be returned by the agent.

    // Copy the data back to the caller
    for(int i = 0; i < bytes.size(); i++) bytes[i] = generic_xact.data[i];
  
    // Should we compare the data when the status is not OK ? Not sure ?
    if(generic_xact.status == SRM_IS_OK && !skip_check) begin

     // Check the read data against each of the field model values.
     foreach(_fields[i]) begin
      // Extract byte enable for field and check if they are all set.
      field_byte_enables = srm_utils::extract_field_enables(byte_enables,
                            _fields[i].get_lsb_pos(), _fields[i].get_n_bits());
      field_byte_enables_on = 1;
      foreach(field_byte_enables[i]) 
        if(field_byte_enables[i] == 0) field_byte_enables_on = 0;

      // Skip read checks for volatile field and if byte enables are off
      if(!_fields[i].is_volatile() && field_byte_enables_on) begin
        new_field_bytes = srm_utils::extract_field(.bytes(bytes), 
                                                 .lsb_pos(_fields[i].get_lsb_pos()),
                                                 .n_bits(_fields[i].get_n_bits()));
        
        current_field_bytes = _fields[i].get_bytes();

        if(!srm_utils::is_same_bytes(.bytes1(new_field_bytes), .bytes2(current_field_bytes))) begin

          // Data Mismatch Detected.
          msg = $sformatf("Expected Data=%s, Got Data=%s for field \"%s\" in register \"%s\" at addr=0x%0x",
              srm_utils::bytes_2_hex(current_field_bytes), srm_utils::bytes_2_hex(new_field_bytes),
              _fields[i].get_name(), get_full_name(), generic_xact.addr);

          if(!handle.skip_read_error_msg) `uvm_error("ReadFieldMismatch", msg);
          handle.append_error(msg);
          handle.generic_xact_status = SRM_READ_DATA_MISMATCH;

        end

      end

     end
   end

  endtask

endclass

`endif
