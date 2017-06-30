`ifndef INCLUDED_srm_base_observer
`define INCLUDED_srm_base_observer

virtual class srm_base_observer;
  string _name;
  function new(string name);
    _name = name;
  endfunction

  virtual function get_name();
    return _name;
  endfunction

  pure virtual function void sample(const ref srm_generic_xact_t xact); 
endclass

`endif
