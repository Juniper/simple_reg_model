//------------------------------------------------------------------------------
// Class: jelly_bean_base_test
//------------------------------------------------------------------------------

class jelly_bean_base_test extends uvm_test;
   `uvm_component_utils( jelly_bean_base_test )

   jelly_bean_env          jb_env;
   jelly_bean_env_config   jb_env_cfg;
   jelly_bean_agent_config jb_agent_cfg;
   jelly_bean_reg_block    jb_reg_block;
   frontdoor_adapter_policy    fd_policy;
   jelly_bean_frontdoor_handle jb_fd_handle;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      jb_reg_block = new("jb_reg_block", null);
      fd_policy = frontdoor_adapter_policy::type_id::create("jb_fd_policy");

      jb_fd_handle = jelly_bean_frontdoor_handle::type_id::create("jb_fd_handle");
      jb_fd_handle.initialize(.adapter_policy(fd_policy), .addr_map_name("reg_map"));
      
      jb_env_cfg = jelly_bean_env_config::type_id::create( "jb_env_cfg" );
      jb_env_cfg.regmodel = jb_reg_block;

      jb_agent_cfg = jelly_bean_agent_config::type_id::create( "jb_agent_cfg" );
      
      if ( ! uvm_config_db#( virtual jelly_bean_if )::get( .cntxt( this ),
                                                           .inst_name( "" ),
                                                           .field_name( "jb_if" ),
                                                           .value( jb_agent_cfg.jb_if ))) begin
         `uvm_error( "jelly_bean_test", "jb_if not found" )
      end
      jb_agent_cfg.regmodel = jb_reg_block;
      jb_env_cfg.jb_agent_cfg = jb_agent_cfg;

      uvm_config_db#(jelly_bean_env_config)::set( .cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "jb_env_cfg" ),
                                                  .value( jb_env_cfg ) );
      jb_env = jelly_bean_env::type_id::create( .name( "jb_env" ), 
                                                .parent( this ) );
   endfunction: build_phase

   virtual function void start_of_simulation_phase( uvm_phase phase );
      super.start_of_simulation_phase( phase );
      uvm_top.print_topology();
   endfunction: start_of_simulation_phase

   virtual function void final_phase(uvm_phase phase);
    $display("SRUN_TEST_PASS");
   endfunction

endclass: jelly_bean_base_test


