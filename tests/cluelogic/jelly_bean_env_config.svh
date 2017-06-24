//------------------------------------------------------------------------------
// Class: jelly_bean_env_config
//------------------------------------------------------------------------------

class jelly_bean_env_config extends uvm_object;
   `uvm_object_utils( jelly_bean_env_config )

   bit has_jb_agent = 1;
   bit has_jb_sb    = 1;
   
   jelly_bean_agent_config jb_agent_cfg;
   jelly_bean_reg_block    regmodel;

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: jelly_bean_env_config


