`ifndef INCLUDED_srm_base_field_svh
`define INCLUDED_srm_base_field_svh

//------------------------------------------------------
// CLASS: srm_base_field
// Base class for a field in a register.
//
// A field is a contingous set of bits accessed indivisibly by sw.
//------------------------------------------------------
virtual class srm_base_field;
  local string _name;
  protected srm_base_reg _parent;
  protected int _n_bits;
  protected int _lsb_pos;
  protected bit _is_initialized; // Derived class also sets it in "set" function.

  local bit _volatile;
  
  //-----------------
  // Group: Initialization
  //-----------------
  
  // Function: new
  function new(string name, srm_base_reg parent, int n_bits, int lsb_pos,
               bit volatile);
    _name = name;
    _parent = parent;
    _n_bits = n_bits;
    _lsb_pos = lsb_pos;
    _volatile = volatile;
  endfunction

  //-----------------
  // Group: Introspection 
  //-----------------
  // Function: get_name
  function string get_name();
    return _name;
  endfunction

  // Function: get_full_name
  function string get_full_name();
    return {_parent.get_full_name(), ".", _name};
  endfunction

  // Function: get_parent
  function srm_base_reg get_parent();
    return _parent;
  endfunction

  // Function: get_n_bits
  function int get_n_bits();
    return _n_bits;
  endfunction

  // Function: get_lsb_pos
  function int get_lsb_pos();
    return _lsb_pos;
  endfunction

  // Function: is_volatile
  function bit is_volatile();
    return _volatile;
  endfunction

  //-------------------------------------
  // Group: Reset
  //-------------------------------------
  // Function: apply_reset
  //
  // Reset the field with the specified reset.
  //
  virtual function void apply_reset(string kind);
    _is_initialized = 0;
  endfunction

  //-------------------
  // Group: Access
  //-------------------

  // Function: get_bytes
  // Virtual function that will be implemented by srm_field.
  pure virtual function srm_data_t get_bytes();

  // Function: set_bytes
  // Virtual function that will be implemented by srm_field.
  pure virtual function void set_bytes(const ref srm_data_t bytes);

endclass

`endif
