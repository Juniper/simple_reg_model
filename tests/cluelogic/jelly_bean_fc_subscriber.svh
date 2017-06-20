//------------------------------------------------------------------------------
// Class: jelly_bean_fc_subscriber
//------------------------------------------------------------------------------

class jelly_bean_fc_subscriber extends uvm_subscriber#( jelly_bean_transaction );
   `uvm_component_utils( jelly_bean_fc_subscriber )

   jelly_bean_transaction jb_tx;

`ifndef CL_USE_MODELSIM
   covergroup jelly_bean_cg;
      flavor_cp:     coverpoint jb_tx.flavor;
      color_cp:      coverpoint jb_tx.color;
      sugar_free_cp: coverpoint jb_tx.sugar_free;
      sour_cp:       coverpoint jb_tx.sour;
      cross flavor_cp, color_cp, sugar_free_cp, sour_cp;
   endgroup: jelly_bean_cg
`endif

   function new( string name, uvm_component parent );
      super.new( name, parent );
`ifndef CL_USE_MODELSIM
      jelly_bean_cg = new;
`endif
   endfunction: new

   function void write( jelly_bean_transaction t );
      jb_tx = t;
`ifndef CL_USE_MODELSIM
      jelly_bean_cg.sample();
`endif
   endfunction: write
endclass: jelly_bean_fc_subscriber

