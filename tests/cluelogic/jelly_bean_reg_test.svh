//------------------------------------------------------------------------------
// Class: jelly_bean_reg_test
//------------------------------------------------------------------------------

class jelly_bean_reg_test extends jelly_bean_base_test;
   `uvm_component_utils( jelly_bean_reg_test )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   task main_phase( uvm_phase phase );
      jelly_bean_reg_sequence jb_reg_seq;

      phase.raise_objection( .obj( this ) );
      jb_reg_seq = jelly_bean_reg_sequence::type_id::create( .name( "jb_reg_seq" ) );

      jb_reg_seq.jb_reg_block = jb_reg_block;
      jb_reg_seq.handle = jb_fd_handle;
      jb_reg_seq.start( .sequencer( jb_env.jb_agent.jb_seqr ) );
     
      $display("\n>>>Starting sequence with backdoor handle\n");
      jb_reg_seq.handle = jb_bd_handle;
      jb_reg_seq.start( .sequencer( jb_env.jb_agent.jb_seqr ) );

      #100ns;
      phase.drop_objection( .obj( this ) );
      
   endtask: main_phase
endclass: jelly_bean_reg_test


