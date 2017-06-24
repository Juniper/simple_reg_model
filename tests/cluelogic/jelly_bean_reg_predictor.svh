//------------------------------------------------------------------------------
// jelly_bean_reg_predictor
//------------------------------------------------------------------------------

class jelly_bean_reg_predictor extends srm_bus_predictor#(jelly_bean_transaction);
  `uvm_component_utils(jelly_bean_reg_predictor)
   
   function new( string name="", uvm_component parent=null );
      super.new( name, parent );
   endfunction: new

  virtual function srm_generic_xact_t bus_2_generic_xact(jelly_bean_transaction tr);
    srm_generic_xact_t xact;
      xact.data = new[1];
      if (tr.command == jelly_bean_types::READ ) begin
        xact.addr = 'h1; // Correspond to the taste register
        xact.data[0] = {6'd0, tr.taste};
      end else begin
        xact.addr = 'h0; // Correspond to the recipe register
        xact.data[0] = {1'b0, tr.sour, tr.sugar_free, tr.color, tr.flavor};
      end
    return xact;
  endfunction

endclass



