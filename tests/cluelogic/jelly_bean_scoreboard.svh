//------------------------------------------------------------------------------
// Class: jelly_bean_scoreboard
//------------------------------------------------------------------------------

class jelly_bean_scoreboard extends uvm_scoreboard;
   `uvm_component_utils( jelly_bean_scoreboard )

   uvm_analysis_export#( jelly_bean_transaction ) jb_analysis_export;
   local jelly_bean_sb_subscriber jb_sb_sub;
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase(uvm_phase phase );
      super.build_phase( phase );
      jb_analysis_export = new( .name( "jb_analysis_export" ), .parent( this ) );
      jb_sb_sub = jelly_bean_sb_subscriber::type_id::create( .name( "jb_sb_sub" ),
                                                             .parent( this ) );
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_analysis_export.connect( jb_sb_sub.analysis_export );
   endfunction: connect_phase

   virtual function void check_jelly_bean_taste( jelly_bean_transaction jb_tx );
      uvm_table_printer p = new;
      if ( jb_tx.flavor == jelly_bean_types::CHOCOLATE && jb_tx.sour &&
           jb_tx.taste == jelly_bean_types::YUMMY ) begin
         `uvm_error( "jelly_bean_scoreboard", 
                     { "You lost sense of taste!\n", jb_tx.sprint( p ) } );
      end else begin
         `uvm_info( "jelly_bean_scoreboard",
                    { "You have a good sense of taste.\n", jb_tx.sprint( p ) },
                    UVM_LOW );
      end
   endfunction: check_jelly_bean_taste

endclass: jelly_bean_scoreboard

