`ifndef INCLUDED_srm_bus_adapter_svh
`define INCLUDED_srm_bus_adapter_svh

//-----------------------------------------------------------------
// CLASS: srm_bus_adapter
// Abstract base class for adapter.
//
// Derived class must override the execute method to convert the generic
// bus operation to a design specific transaction.
//-----------------------------------------------------------------
class srm_bus_adapter extends uvm_object;

  `uvm_object_utils(srm_bus_adapter)

  // Variable: no_response_generated
  // Update the model value after access to the design automatically.
  bit no_response_generated;

  function new(string name="");
    super.new(name);
    no_response_generated = 0;
  endfunction

 virtual task execute(ref srm_generic_xact_t generic_xact);
 endtask

endclass

`endif
