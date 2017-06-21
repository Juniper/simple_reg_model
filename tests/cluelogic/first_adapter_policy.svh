`ifndef INCLUDED_first_adapter_policy
`define INCLUDED_first_adapter_policy

class first_adapter_policy extends srm_adapter_policy;
  function bit is_correct_adapter(srm_bus_adapter adapter);
    return 1;
  endfunction
endclass

`endif
