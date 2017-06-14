`ifndef INCLUDED_srm_base_reg_svh
`define INCLUDED_srm_base_reg_svh

typedef class srm_base_field;
//--------------------------------------------------------
// CLASS: srm_base_reg
// Register base model
//
// Register without the template data. This allows the base 
// field to access the contents of the register and updates 
// coming from the monitor to update the value.
//--------------------------------------------------------
class srm_base_reg extends srm_component;
  local srm_base_field _fields[$];

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

  //------------------
  // Group: Introspection
  //-------------------
  virtual function int get_width_bytes();
    int num_bits = 0;
    foreach(_fields[i]) num_bits += _fields[i].get_n_bits();
    assert( num_bits % 8 == 0); // Must be byte aligned.
    return num_bits/8;
  endfunction

  // Function: get_num_fields
  // Return the number of fields in the entry.
  //
  virtual function int get_num_fields();
    return _fields.size();
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
  virtual task load(srm_handle handle);
    srm_data_t bytes;
    srm_byte_enable_t byte_enables;
    int num_bytes = get_width_bytes(); 

    bytes = new[num_bytes];
    byte_enables = new[num_bytes];
    for(int i = 0; i < num_bytes; i++) byte_enables[i] = 1;

    __read_bytes(handle, bytes, byte_enables);

    set_bytes(bytes);
    
  endtask

  // Task: store
  // Store the model data into the design.
  //
  virtual task store(srm_handle handle);
    srm_data_t bytes;
    srm_byte_enable_t byte_enables;
    int num_bytes = get_width_bytes(); 

    bytes = get_bytes();
    byte_enables = new[num_bytes];
    for(int i = 0; i < num_bytes; i++) byte_enables[i] = 1;
  
    __write_bytes(handle, bytes, byte_enables);

  endtask

  //------------------
  // Group: Model Update
  //-------------------
  //
  virtual function void agent_update(const ref srm_bus_xact xact);
    if(xact.kind == SRM_WRITE) begin
    end
    else begin
    end
  endfunction

  //------------------
  // Group: Private API
  //-------------------

  // Function: __write_bytes
  // Send the bus xact to the adapter class. if auto predict is on then the
  // model value is updated at the end otherwise done later by the xact from monitor.
  //
  // For use by framework classes only.
  virtual task __write_bytes(srm_handle handle, const ref srm_data_t bytes, 
                       const ref srm_byte_enable_t byte_enables);
    srm_bus_xact bus_xact;
    srm_bus_adapter adapter;

    bus_xact.kind = SRM_WRITE;
    bus_xact.addr = get_offset(handle.addr_map_name);
    bus_xact.data = bytes;
    bus_xact.byte_enables = byte_enables;

    // Launch the operation
    adapter = handle.adapter_policy.get_adapter(this);
    adapter.execute(bus_xact);

    if(handle.auto_predict_model) begin
      agent_update(bus_xact);
    end

  endtask


  // Function: __read_bytes
  // Read the data from the register.
  //
  // Checks that the read data matches the model value. Will report
  // error for non volatile fields. Volatile fields are silently updated.
  virtual task __read_bytes(srm_handle handle, ref srm_data_t bytes,
                            const ref srm_byte_enable_t byte_enables);
    srm_bus_xact bus_xact;
    srm_bus_adapter adapter;
    srm_data_t current_field_bytes, new_field_bytes;
    string msg;

    bus_xact.kind = SRM_READ;
    bus_xact.addr = get_offset(handle.addr_map_name);
    bus_xact.data = bytes;
    bus_xact.byte_enables = byte_enables;

    // Launch the operation
    adapter = handle.adapter_policy.get_adapter(this);
    adapter.execute(bus_xact);
    
    handle.bus_xact_status = bus_xact.status;

    // Wait for the read to complete and data to be returned by the agent.

    // Copy the data back to the caller
    for(int i = 0; i < bytes.size(); i++) bytes[i] = bus_xact.data[i];
   
   if(bus_xact.status == SRM_IS_OK) begin

     // Check the read data against each of the field model values.
     foreach(_fields[i]) begin

      new_field_bytes = srm_utils::extract_field(.bytes(bytes), 
                                                 .lsb_pos(_fields[i].get_lsb_pos()),
                                                 .n_bits(_fields[i].get_n_bits()));

      // Skip read checks for volatile field. instead just update.
      if(_fields[i].is_volatile()) begin
        _fields[i].set_bytes(new_field_bytes);
      end
      else begin

        // Do Read check for each of the fields.
        
        current_field_bytes = _fields[i].get_bytes();

        if(!srm_utils::is_same_bytes(.bytes1(new_field_bytes), .bytes2(current_field_bytes))) begin

          // Data Mismatch Detected.
          msg = $sformatf("Expected Data=%s, Got Data=%s for field \"%s\" in register \"%s\" at addr=0x%0x",
              srm_utils::bytes_2_hex(current_field_bytes), srm_utils::bytes_2_hex(new_field_bytes),
              _fields[i].get_name(), get_full_name(), bus_xact.addr);

          if(!handle.skip_read_error_msg) `uvm_error("ReadFieldMismatch", msg);
          handle.append_error(msg);
          handle.bus_xact_status = SRM_READ_DATA_MISMATCH;

        end

      end

     end
   end

  endtask

endclass

`endif
