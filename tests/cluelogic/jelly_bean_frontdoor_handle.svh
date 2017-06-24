`ifndef INCLUDED_jelly_bean_frontdoor_handle
`define INCLUDED_jelly_bean_frontdoor_handle

class jelly_bean_frontdoor_handle extends srm_base_handle;

  `uvm_object_utils(jelly_bean_frontdoor_handle)

  function new(string name="");
    super.new(name);
  endfunction

  virtual function void initialize(srm_adapter_policy adapter_policy, string addr_map_name);
    super.initialize(adapter_policy, addr_map_name);
  endfunction

endclass

`endif
