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
`ifndef INCLUDED_srm_base_reg_svh
`define INCLUDED_srm_base_reg_svh

typedef class srm_base_field;
//--------------------------------------------------------
// CLASS: srm_base_reg
// Base class for the register.
//
// Do not directly instantiate this class. It is used by the framework
// to deal with template registers in a generic way.
//--------------------------------------------------------
virtual class srm_base_reg extends srm_component;
  protected srm_base_field _fields[$];
  protected int _reset_kinds[string];
  
  //------------------
  // Group: Initialization
  //-------------------
  
  // Function: new
  function new(string name, srm_component parent);
    super.new(name, parent);
  endfunction

  // Function: add_field
  //
  // Add a field to the register.
  //
  // A register maintains a collection of fields. The fields need not
  // be sorted in any particular order.
  //
  function void add_field(srm_base_field f);
    _fields.push_back(f);
  endfunction

  // Function: set_policy
  //
  // Sets the policy on all the fields of the register .
  //
  // This is a helper function. It is also possible to set different policy on
  // each field by setting it directly on the field.
  //
  virtual function void set_policy(string addr_map_name, srm_base_field_policy policy);
    foreach(_fields[i]) begin
      _fields[i].set_policy(addr_map_name, policy);
    end
  endfunction

  //------------------
  // Group: Introspection
  //-------------------

  // Function: get_width_bytes
  //
  // Returns the width of the register in bytes
  //
  // Add up the number of bits in each field. The register by definition
  // need to be byte aligned. Hence the user must add reserved fields to ensure
  // that this is always true.
  //
  virtual function int get_width_bytes();
    int num_bits = 0;
    foreach(_fields[i]) num_bits += _fields[i].get_n_bits();
    assert( num_bits % 8 == 0); // Must be byte aligned.
    return num_bits/8;
  endfunction

  // Function: get_size
  // FIXME: Return the number of bytes in address map. SHould it not be the same
  // for all address maps since the field is the same ?
  //
  // ~addr_map_name~ FIXME: May not be required.
  // For a register it is the width of the register. The value is cached for
  // performance reason.
  virtual function srm_addr_t get_size(string addr_map_name);
    if(!_size_table.exists(addr_map_name)) 
      _size_table[addr_map_name] = get_width_bytes(); // Cache
    return _size_table[addr_map_name];
  endfunction

  // Function: get_num_fields
  //
  // Return the number of fields in the entry.
  //
  virtual function int get_num_fields();
    return _fields.size();
  endfunction

  //------------------
  // Group: Reset
  //-------------------
 
  // Function: set_reset_kind
  //
  // Set the type of reset supported on the register.
  //
  // The spec needs to ensure same kind supported by all the fields
  // in the register.
  virtual function void set_reset_kind(string kind);
    _reset_kinds[kind] = 1;
  endfunction

  // Function: is_resettable
  //
  // Return true if the register supports this kind of reset.
  //
  // ~kind~ is the type of reset.
  //
  virtual function bit is_resettable(string kind);
    return _reset_kinds.exists(kind);
  endfunction
  
  // Function: reset
  //
  // Reset all the fields of the register.
  //
  // ~kind~ is the type of reset.
  // This has no effect on the register if the register does not support that
  // kind of reset.
  virtual function void reset(string kind);
    if(is_resettable(kind)) begin
      foreach(_fields[i]) _fields[i].reset(kind);
    end
  endfunction


  //------------------
  // Group: Access Model Only 
  //-------------------
  
  // Function: get_bytes
  //
  // Return the value of the register model as a list of bytes.
  //
  // Get the value from the constituent fields and merge them together. This is
  // used by the framework to treat registers in a generic fashion.
  //
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
  //
  // Set the value in the register model to the list of bytes.
  //
  // ~bytes~ are the list of bytes that are to be written to the model.
  // Extract the field values from the list of bytes and set them.
  //
  virtual function void set_bytes(const ref srm_data_t bytes);
    srm_data_t field_bytes;

    foreach(_fields[i]) begin
      field_bytes = srm_utils::extract_field(.bytes(bytes), .lsb_pos(_fields[i].get_lsb_pos()),
                    .n_bits(_fields[i].get_n_bits()));
      _fields[i].set_bytes(field_bytes);
    end
  endfunction

  //------------------
  // Group: Access Model+Design
  //-------------------
  
  // Task: load
  //
  // Load the design data into the model.
  //
  // ~handle~ Options required for the read.
  // Read the data from the design and silently update the model.
  // No checking is done for non volatile fields.
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
  //
  // Store the model data into the design.
  //
  // ~handle~ Options required for the write.
  // Writes the data from the model to the design. All the byte enables
  // are turned on for this write.
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
  //
  // Attach an observer to itself.
  //
  // ~observer~ is the coverage observer attached to the register.
  //
  virtual function void attach(srm_base_coverage observer);
    _coverage_cbs.push_back(observer);
  endfunction

  // Function: detach
  //
  // Detach an observer if it exists.
  // 
  // ~observer~ is the instance to be detached.
  //
  virtual function void detach(srm_base_coverage observer);
    foreach(_coverage_cbs[i]) begin
      if(_coverage_cbs[i] == observer) _coverage_cbs.delete(i);
    end
  endfunction

  // Function: detach_all
  //
  // Detach all observers
  //
  // Remove all the observers from the node.
  //
  virtual function void detach_all();
    _coverage_cbs = {};
  endfunction

  // Function: post_write
  //
  // Post write functional callback.
  //
  // Calls ~post_write~ on all the callback clients after the write task completes.
  // Both the design and model have been updated before this gets invoked.
  virtual function void post_write();
    for(int i = 0; i < _coverage_cbs.size(); i++) begin
      _coverage_cbs[i].post_write(this);
    end
  endfunction

  // Function: post_read
  //
  // Post read functional coverage.
  //
  // Calls post_read on all the callback clients after the read task completes.
  // The model has already been updated with the read data before this is invoked.
  //
  virtual function void post_read();
    for(int i = 0; i < _coverage_cbs.size(); i++) begin
      _coverage_cbs[i].post_read(this);
    end
  endfunction

  // Function: sample_xact
  //
  // Generate xact functional covearage.
  // FIXME: What is the use case ?
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
    obj._reset_kinds = _reset_kinds;
  endfunction

  // Function: get_index
  //
  // This is for callback to access the index of the array entry.
  //
  virtual function srm_addr_t get_index();
    return 0;
  endfunction
 
  // Function: __write_bytes
  // Send the bus xact to the adapter class.
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
