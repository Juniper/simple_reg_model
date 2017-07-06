`ifndef INCLUDED_srm_reg_array_svh
`define INCLUDED_srm_reg_array_svh

//----------------------------------------------------------
// CLASS: srm_reg_array
// A register array is a register with number of entries > 1.
//----------------------------------------------------------

class srm_reg_array #(type T = int) extends srm_component;
  protected srm_addr_t _num_entries;
  protected srm_array_entry#(T) _prototype;
  protected srm_array_entry#(T) _entries[srm_addr_t];
  
  //-----------------
  //Group: Initialization
  //-----------------

  // Function: new
  function new(string name, srm_component parent, srm_addr_t num_entries);
    super.new(name, parent);
    _num_entries = num_entries;
  endfunction

  //-----------------------
  // Group: Introspection 
  //-----------------------
  function int get_num_entries();
    return _num_entries;
  endfunction

  //-----------------------
  // Group: Composite 
  //-----------------------
  function srm_array_entry#(T) entry_at(srm_addr_t index);
    string name;
    srm_array_entry#(T) entry;

    if(index >= _num_entries) begin
      `uvm_fatal("TbConfigurationError", 
        $psprintf("Index %0d is more than array \"%s\" size of %0d entries",
                  index, get_full_name(), _num_entries));
    end else if(!_entries.exists(index)) begin
      name = $psprintf("%s_%0d", get_name(), index);
      entry = _prototype.clone(index);
      _entries[index] = entry;
    end 

    return _entries[index];
  endfunction


  // Function: set_policy
  // Sets the policy on all the field nodes.
  //
  virtual function void set_policy(string addr_map_name, srm_base_policy policy);
    _prototype.set_policy(addr_map_name, policy);
  endfunction

  //------------------
  // Group: Model+Design Access 
  //-------------------
  
  // Task: load
  // Load all the entries of the model from the design.
  //
  // No checking is done and the model is silently updated.
  virtual task load(srm_base_handle handle);
    srm_array_entry#(T) entry;
    for(int i = 0; i < get_num_entries(); i++) begin
      entry = entry_at(i);
      entry.load(handle);
    end
  endtask

  // Task: store
  // Store all the entries from the model into the design.
  //
  virtual task store(srm_base_handle handle);
    srm_array_entry#(T) entry;
    for(int i = 0; i < get_num_entries(); i++) begin
      entry = entry_at(i);
      entry.store(handle);
    end
  endtask

  //------------------
  // Group: Reset
  //-------------------
  
  // Function: is_resettable
  // If the entry is resettable then the array is resettable.
  virtual function bit is_resettable(string kind);
    return _prototype.is_resettable(kind);
  endfunction

  // Function: is_reset_present();
  virtual function bit is_reset_present();
    return _prototype.is_reset_present();
  endfunction

  // Function: reset
  // Reset the prototype for future entries and delete existing entries.
  virtual function void reset(string kind);
    // If reset succeeds then all entries must be deleted.
    if(_prototype.is_resettable(kind)) begin
      _prototype.reset(kind);
      foreach(_entries[i]) _entries[i].reset(kind);
    end
  endfunction

  virtual function string get_last_reset_kind();
    return _prototype.get_last_reset_kind();
  endfunction

  //------------------
  // Group: Debug
  //------------------
  
  // Function: get_num_active_entries
  // Return the number of entries that have been created.
  // Useful for unit testing the sparse feature.
  virtual function int get_num_active_entries();
    return _entries.size();
  endfunction

  // Function: get_size
  // Return the number of bytes in address map.
  //
  virtual function srm_addr_t get_size(string addr_map_name);
    if(!_size_table.exists(addr_map_name))
      _size_table[addr_map_name] = _prototype.get_width_bytes() * _num_entries;
    return _size_table[addr_map_name];
  endfunction

  //----------------------
  // Group: Coverage Interface 
  //----------------------

  // Function: attach
  // Attach an observer to itself.
  //
  virtual function void attach(srm_base_coverage observer);
    _prototype._coverage_cbs.push_back(observer);
  endfunction

  // Function: detach
  // Detach an observer if it exists.
  //
  virtual function void detach(srm_base_coverage observer);
    foreach(_prototype._coverage_cbs[i]) begin
      if(_prototype._coverage_cbs[i] == observer) _prototype._coverage_cbs.delete(i);
    end
  endfunction

  // Function: detach_all
  // Detach all observers
  virtual function void detach_all();
    _prototype._coverage_cbs = {};
  endfunction

  // Function: get_num_coverage_cbs
  // Returns the number of coverage callbacks on the node.
  //
  // For unit testing.
  virtual function int get_num_coverage_cbs();
    return _prototype._coverage_cbs.size();
  endfunction


endclass

`endif
