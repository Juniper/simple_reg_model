`ifndef INCLUDED_srm_adapter_policy_svh
`define INCLUDED_srm_adapter_policy_svh

//-----------------------------------------------------------------
// CLASS: srm_adapter_policy
// Select the correct adapter.
//
// Walk from the leaf to the root looking for correct adapter.
//
//-----------------------------------------------------------------
class srm_adapter_policy extends uvm_object;
  `uvm_object_utils(srm_adapter_policy)

  srm_bus_adapter adapters[$];

  function new(string name="");
    super.new(name);
  endfunction

  virtual function srm_bus_adapter get_adapter(srm_component obj);
    srm_component ptr = obj;
    srm_bus_adapter adapters[$];

    // Walkup from leaf to root looking for correct adapter.
    while(ptr != null) begin
      adapters = ptr.get_adapters();
      for(int i = 0; i < adapters.size(); i++) begin
        if(is_correct_adapter(adapters[i])) return adapters[i];
      end
      ptr = ptr.get_parent();
    end

    return null;
  endfunction

  virtual function bit is_correct_adapter(srm_bus_adapter adapter);
    return 0;
  endfunction
  
endclass

`endif
