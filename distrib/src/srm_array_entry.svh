`ifndef INCLUDED_srm_array_entry_svh
`define INCLUDED_srm_array_entry_svh

//--------------------------------------------------------
// CLASS: srm_array_entry
// Models the entry of the register array.
//--------------------------------------------------------
virtual class srm_array_entry#(type T = int) extends srm_reg#(T);
  local srm_addr_t _index;   // For address computation in array.
  
  // Function: new
  function new(string name, srm_component parent, srm_addr_t index);
    super.new(name, parent);
    _index = index;
  endfunction
  
  //------------------
  // Group: Private 
  //-------------------
  // Function: clone
  // Abstract method that is overwritten by the derived class.
  // Should create a clone of the prototype at the specified index.
  //
  pure virtual function srm_array_entry#(T) clone(srm_addr_t index);

  // Function: initialize
  // Private function to create the clone.
  protected function void __initialize(srm_array_entry#(T) obj);
    super.__initialize(obj);
  endfunction

  //----------------------
  // Group: Address computation 
  //----------------------

  // Function: get_index
  // Returns the index of the entry.
  virtual function srm_addr_t get_index();
    return _index;
  endfunction

  // Function: get_offset
  // Get the offset of entry 0 and then add the index*width.
  //
  virtual function srm_addr_t get_offset(string addr_map_name);
    srm_addr_t offset = _parent.get_offset(addr_map_name);
    return offset + (_index * get_width_bytes());
  endfunction


  
endclass

`endif
