`ifndef INCLUDED_srm_reg_array_svh
`define INCLUDED_srm_reg_array_svh

//----------------------------------------------------------
// CLASS: srm_reg_array
// A register array is a register with number of entries > 1.
//----------------------------------------------------------

class srm_reg_array #(type T = int) extends srm_component;
  local srm_addr_t _num_entries;
  protected srm_array_entry#(T) _prototype;
  local srm_array_entry#(T) _entries[srm_addr_t];
  
  //-----------------
  //Group: Initialization
  //-----------------

  // Function: new
  function new(string name, srm_component parent, srm_addr_t num_entries);
    super.new(name, parent);
    _num_entries = num_entries;
  endfunction

  //-----------------------
  // Composite 
  //-----------------------
  function srm_array_entry#(T) entry_at(srm_addr_t index);
    string name;
    srm_array_entry#(T) entry;

    if(!_entries.exists(index)) begin
      //FIXME: need to make it unidirectional so that the node tree does not see
      name = $psprintf("%s_%0d", get_name(), index);
      entry = _prototype.clone(index);
      _entries[index] = entry;
    end 
    return _entries[index];
  endfunction

endclass

`endif
