typedef class jelly_bean_scoreboard;
   
//------------------------------------------------------------------------------
// Class: jelly_bean_sb_subscriber
//------------------------------------------------------------------------------

class jelly_bean_sb_subscriber extends uvm_subscriber#( jelly_bean_transaction );
   `uvm_component_utils( jelly_bean_sb_subscriber )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void write( jelly_bean_transaction t );
      jelly_bean_scoreboard jb_sb;
      
      $cast( jb_sb, m_parent );
      jb_sb.check_jelly_bean_taste( t );
   endfunction: write
   
endclass: jelly_bean_sb_subscriber

