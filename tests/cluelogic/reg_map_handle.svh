`ifndef INCLUDED_reg_map_handle
`define INCLUDED_reg_map_handle

class reg_map_handle extends srm_handle;

  // Should we make it into factory.
  function new(srm_adapter_policy adapter_policy);
    super.new(adapter_policy, "reg_map");
    auto_predict_model = 1;
  endfunction

endclass

`endif
