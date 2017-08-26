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

 function new(string name="");
  super.new(name);
 endfunction

 virtual task execute(ref srm_generic_xact_t generic_xact, int seq_priority);
 endtask

endclass

`endif
