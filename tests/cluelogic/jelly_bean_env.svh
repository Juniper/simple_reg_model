//------------------------------------------------------------------------------
// Class: jelly_bean_env
//------------------------------------------------------------------------------

class jelly_bean_env extends uvm_env;
   `uvm_component_utils( jelly_bean_env )

   jelly_bean_env_config    jb_env_cfg;
   jelly_bean_agent         jb_agent;
   jelly_bean_fc_subscriber jb_fc_sub;
   jelly_bean_scoreboard    jb_sb;
   jelly_bean_reg_predictor jb_reg_predictor;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      if ( ! uvm_config_db#( jelly_bean_env_config )::get
           ( .cntxt( this ),
             .inst_name( "" ),
             .field_name( "jb_env_cfg" ),
             .value( jb_env_cfg ) ) ) begin
         `uvm_fatal( get_name(), "jb_env_cfg not found" )
      end

      uvm_config_db#( jelly_bean_agent_config )::set( .cntxt( this ), 
                                                      .inst_name( "jb_agent*" ),
                                                      .field_name( "jb_agent_cfg" ),
                                                      .value( jb_env_cfg.jb_agent_cfg ) );
      jb_agent = jelly_bean_agent::type_id::create( .name( "jb_agent" ),
                                                    .parent( this ) );
      jb_reg_predictor = jelly_bean_reg_predictor::type_id::create( .name( "jb_reg_predictor" ),
                                                                    .parent( this ) );
      if ( jb_env_cfg.has_jb_sb ) begin
         jb_sb = jelly_bean_scoreboard::type_id::create( .name( "jb_sb" ),
                                                         .parent( this ) );
      end
      jb_fc_sub = jelly_bean_fc_subscriber::type_id::create( .name( "jb_fc_sub" ),
                                                             .parent( this ) );
    endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_agent.jb_ap.connect( jb_fc_sub.analysis_export );
      jb_agent.jb_ap.connect( jb_sb.jb_analysis_export );
      if ( jb_env_cfg.jb_reg_block.get_parent() == null ) begin // if the top-level env
         jb_env_cfg.jb_reg_block.reg_map.set_sequencer( .sequencer( jb_agent.jb_seqr ),
                                                        .adapter( jb_agent.jb_reg_adapter ) );
      end
      jb_env_cfg.jb_reg_block.reg_map.set_auto_predict( .on( 0 ) );
      jb_reg_predictor.map     = jb_env_cfg.jb_reg_block.reg_map;
      jb_reg_predictor.adapter = jb_agent.jb_reg_adapter;
      jb_agent.jb_ap.connect( jb_reg_predictor.bus_in );
   endfunction: connect_phase

endclass: jelly_bean_env


