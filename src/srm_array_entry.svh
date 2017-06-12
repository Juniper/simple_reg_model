`ifndef INCLUDED_srm_array_entry_svh
`define INCLUDED_srm_array_entry_svh

//--------------------------------------------------------
// CLASS: srm_array_entry
// Models the entry of the register array.
//--------------------------------------------------------
class srm_array_entry#(type T = int) extends srm_reg#(T);
  local srm_addr_t _index;   // For address computation in array.
  
  // Function: new
  function new(string name, srm_component parent, srm_addr_t index);
    super.new(name, parent);
    _index = index;
  endfunction
  
  //------------------
  // Group: Private 
  //-------------------
  virtual function srm_array_entry#(T) clone(srm_addr_t index);
    srm_array_entry#(T) obj;
    assert(!"Derived class  must override it");
    return obj;
  endfunction

  //----------------------
  // Group: Address computation 
  //----------------------

  // Function: get_address
  // Return the address of the register.
  virtual function srm_addr_t get_address(string addr_map_name);
    string key;
    srm_addr_t base_addr;

    base_addr = _parent.get_address(addr_map_name);
    return base_addr + _index * get_width_bytes();
  endfunction

endclass

`endif
