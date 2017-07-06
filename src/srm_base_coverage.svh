`ifndef INCLUDED_srm_base_coverage
`define INCLUDED_srm_base_coverage

typedef class srm_base_reg;

class srm_base_coverage;
  string _name;
  function new(string name);
    _name = name;
  endfunction

  virtual function get_name();
    return _name;
  endfunction

  virtual function void post_write(srm_base_reg entry); 
    // Add code for fcov of writes.
  endfunction

  virtual function void post_read(srm_base_reg entry); 
    // Add code for fcov of reads.
  endfunction

endclass

`endif
