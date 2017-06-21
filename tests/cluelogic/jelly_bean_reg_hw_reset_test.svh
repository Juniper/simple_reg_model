
//------------------------------------------------------------------------------
// Class: jelly_bean_reg_hw_reset_test
// FIXME: using build in sequence. Currently not supported.
//------------------------------------------------------------------------------

class jelly_bean_reg_hw_reset_test extends jelly_bean_base_test;
   `uvm_component_utils( jelly_bean_reg_hw_reset_test )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   task main_phase( uvm_phase phase );
      uvm_reg_hw_reset_seq reg_hw_reset_seq;

      phase.raise_objection( .obj( this ) );
      // FIXME: build in uvm sequence not supported.
`ifdef SPS
      reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create( .name( "reg_hw_reset_seq" ) );
      reg_hw_reset_seq.jb_reg_block = jb_reg_block;
      reg_hw_reset_seq.handle = handle;
      reg_hw_reset_seq.start( .sequencer( jb_env.jb_agent.jb_seqr ) );
`endif      
      phase.drop_objection( .obj( this ) );
   endtask: main_phase
endclass: jelly_bean_reg_hw_reset_test


