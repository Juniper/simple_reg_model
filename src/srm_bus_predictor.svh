`ifndef INCLUDED_srm_bus_predictor
`define INCLUDED_srm_bus_predictor

// Class: srm_bus_predictor
// Abstract base class for updating the register model with the transaction on the bus.
//
class srm_bus_predictor #(type BUSTYPE=int) extends uvm_component;

  `uvm_component_param_utils(srm_bus_predictor#(BUSTYPE))

  // Variable: bus_in
  // Observed bus transacations of type ~BUSTYPE~ are received from this
  // port and processed.
  //
  uvm_analysis_imp #(BUSTYPE, srm_bus_predictor #(BUSTYPE)) bus_in;

  // Variable: regmodel
  // This is used to update the corresponding register. Must be configured before
  // the run phase.
  srm_component regmodel;

  // Function: new
  // Create a new instance of this type, giving the optional ~name~ and ~parent~.
  //
  function new(string name, uvm_component parent);
    super.new(name, parent);
    bus_in = new("bus_in", this);
  endfunction

  // Function: bus2reg
  // Convert the bus transacation to a generic register transaction
  // FIXME:Pure is not compiling.
  virtual function srm_generic_xact_t bus_2_generic_xact(BUSTYPE tr);
    srm_generic_xact_t x;
    return x;
  endfunction

  // Function: write
  // Not a user level method. Do not call directly.
  virtual function void write(BUSTYPE tr);
    srm_generic_xact_t xact;
    srm_component root;

    xact = bus_2_generic_xact(tr);
    root = regmodel.get_root_node();
    root.predictor_update(xact);
  endfunction

endclass

`endif
