//------------------------------------------------------------------------------
// jelly_bean_reg_predictor
//------------------------------------------------------------------------------

class jelly_bean_reg_predictor extends srm_bus_predictor#(jelly_bean_transaction);
  `uvm_component_utils(jelly_bean_reg_predictor)
   
   function new( string name="", uvm_component parent=null );
      super.new( name, parent );
   endfunction: new

  virtual function srm_bus_xact bus2reg(jelly_bean_transaction tr);
    srm_bus_xact xact;
    return xact;
  endfunction

endclass



