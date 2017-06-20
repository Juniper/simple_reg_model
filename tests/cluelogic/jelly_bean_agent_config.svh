
//--------------------------------------------------------------------------
// Class: jelly_bean_agent_config
//--------------------------------------------------------------------------

class jelly_bean_agent_config extends uvm_object;
   `uvm_object_utils( jelly_bean_agent_config )

   uvm_active_passive_enum active = UVM_ACTIVE;
   bit has_jb_fc_sub = 1; // switch to instantiate a functional coverage subscriber

   virtual jelly_bean_if jb_if;

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: jelly_bean_agent_config


