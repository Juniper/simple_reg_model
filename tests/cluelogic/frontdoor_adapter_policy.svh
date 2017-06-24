`ifndef INCLUDED_frontdoor_adapter_policy
`define INCLUDED_frontdoor_adapter_policy

class frontdoor_adapter_policy extends srm_adapter_policy;
  `uvm_object_utils(frontdoor_adapter_policy)

  function new(string name="");
    super.new(name);
  endfunction

  function bit is_correct_adapter(srm_bus_adapter adapter);
    if(adapter.get_name() == "jb_fd_adapter")
      return 1;
  endfunction
endclass

`endif
