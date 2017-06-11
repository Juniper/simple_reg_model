`ifndef INCLUDED_srm_bus_adapter_svh
`define INCLUDED_srm_bus_adapter_svh

//-----------------------------------------------------------------
// CLASS: srm_bus_adapter
// Abstract base class for adapter.
//
// Derived class must override the execute method to convert the generic
// bus operation to a design specific transaction.
//-----------------------------------------------------------------
virtual class srm_bus_adapter extends uvm_object;

  function new(string name="");
    super.new(name);
  endfunction

 pure virtual task execute(ref srm_bus_xact bus_op);

endclass

`endif
