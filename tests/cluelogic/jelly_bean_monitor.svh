//------------------------------------------------------------------------------
// Class: jelly_bean_monitor
//------------------------------------------------------------------------------

class jelly_bean_monitor extends uvm_monitor;
   `uvm_component_utils( jelly_bean_monitor )

   uvm_analysis_port#( jelly_bean_transaction ) jb_ap;

   virtual jelly_bean_if jb_if;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jb_ap = new( .name( "jb_ap" ), .parent( this ) );
   endfunction: build_phase

   task main_phase( uvm_phase phase );
      forever begin
         jelly_bean_transaction jb_tx;
         @jb_if.slave_cb;
         if ( jb_if.command == jelly_bean_types::READ ) begin
            jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
            jb_tx.command = jelly_bean_types::command_e'( jb_if.command );
            @jb_if.master_cb;
            jb_tx.taste = jelly_bean_types::taste_e'( jb_if.taste );
            jb_ap.write( jb_tx );
         end else if ( jb_if.command == jelly_bean_types::WRITE &&
                       jb_if.slave_cb.flavor != jelly_bean_types::NO_FLAVOR ) begin
            jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
            jb_tx.command    = jelly_bean_types::command_e'( jb_if.command );
            jb_tx.flavor     = jelly_bean_types::flavor_e'( jb_if.slave_cb.flavor );
            jb_tx.color      = jelly_bean_types::color_e'( jb_if.slave_cb.color );
            jb_tx.sugar_free = jb_if.slave_cb.sugar_free;
            jb_tx.sour       = jb_if.slave_cb.sour;
            jb_ap.write( jb_tx );
         end
      end
   endtask: main_phase
endclass: jelly_bean_monitor

