`ifndef INCLUDED_srm_array_entry_svh
`define INCLUDED_srm_array_entry_svh

//--------------------------------------------------------
// CLASS: srm_array_entry
// Models the entry of the register array.
//--------------------------------------------------------
virtual class srm_array_entry#(type T = int) extends srm_reg#(T);
  local srm_addr_t _index;   // For address computation in array.
  
  // Function: new
  function new(string name, srm_component parent, srm_addr_t index, 
                                                  string reset_kind);
    super.new(name, parent);
    _index = index;
    _last_reset_kind = reset_kind;
  endfunction
  
  //------------------
  // Group: Private 
  //-------------------
  pure virtual function srm_array_entry#(T) clone(srm_addr_t index);

  //----------------------
  // Group: Address computation 
  //----------------------

  // Function: get_offset
  // Get the offset of entry 0 and then add the index*width.
  //
  virtual function srm_addr_t get_offset(string addr_map_name);
    srm_addr_t offset = _parent.get_offset(addr_map_name);
    return offset + (_index * get_width_bytes());
  endfunction


  
endclass

`endif
