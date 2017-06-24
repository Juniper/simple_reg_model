//------------------------------------------------------------------------------
// Class: jelly_bean_agent
//------------------------------------------------------------------------------

class jelly_bean_agent extends uvm_agent;
   `uvm_component_utils( jelly_bean_agent )

   uvm_analysis_port #(jelly_bean_transaction) jb_ap;

   jelly_bean_agent_config jb_agent_cfg;
   jelly_bean_sequencer    jb_seqr;
   jelly_bean_driver       jb_drvr;
   jelly_bean_monitor      jb_mon;
   jelly_bean_frontdoor_adapter  jb_fd_adapter;
   jelly_bean_reg_predictor jb_reg_predictor;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      if ( ! uvm_config_db#( jelly_bean_agent_config )::get( .cntxt( this ), 
                                                             .inst_name ( "" ), 
                                                             .field_name( "jb_agent_cfg" ),
                                                             .value( jb_agent_cfg ))) begin
         `uvm_error( "jelly_bean_agent", "jb_agent_cfg not found" )
      end

      jb_ap = new(.name("jb_ap"), .parent(this));

      if ( jb_agent_cfg.active == UVM_ACTIVE ) begin
         jb_seqr = jelly_bean_sequencer::type_id::create( .name( "jb_seqr" ), 
                                                          .parent( this ) );
         jb_drvr = jelly_bean_driver::type_id::create( .name( "jb_drvr" ), 
                                                       .parent( this ) );
         jb_fd_adapter = jelly_bean_frontdoor_adapter::type_id::create(.name("jb_fd_adapter"),
                                                                  .parent(this));
         jb_reg_predictor = jelly_bean_reg_predictor::type_id::create(.name("jb_predictor"),
                                                                       .parent(this));
      end
      jb_mon = jelly_bean_monitor::type_id::create( .name( "jb_mon" ),
                                                    .parent( this ) );

   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );

      jb_mon.jb_if = jb_agent_cfg.jb_if;
      if ( jb_agent_cfg.active == UVM_ACTIVE ) begin
         jb_drvr.seq_item_port.connect( jb_seqr.seq_item_export );
         jb_drvr.jb_if = jb_agent_cfg.jb_if;
         jb_fd_adapter.set_sequencer(jb_seqr);
         jb_agent_cfg.regmodel.add_adapter(jb_fd_adapter);
         jb_mon.jb_ap.connect( jb_reg_predictor.bus_in );
         jb_reg_predictor.regmodel = jb_agent_cfg.regmodel;
         jb_reg_predictor.addr_map_name = "reg_map";
      end
      jb_mon.jb_ap.connect(jb_ap);
   endfunction: connect_phase
endclass: jelly_bean_agent

