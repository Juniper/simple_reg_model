//------------------------------------------------------------------------------
// Class: jelly_bean_frontdoor_adapter
// Executes the transaction on the sequencer.
//------------------------------------------------------------------------------

class jelly_bean_frontdoor_adapter extends srm_bus_adapter;

   `uvm_object_utils(jelly_bean_frontdoor_adapter)

   jelly_bean_sequencer _sqr;

   function new(string name = "");
      super.new(name);
   endfunction: new

   function void set_sequencer(jelly_bean_sequencer sqr);
    _sqr = sqr;
   endfunction

   class jelly_bean_adapter_sequence extends uvm_sequence#(jelly_bean_transaction);
      jelly_bean_transaction xact;
      function new(string name="");
        super.new(name);
      endfunction

      task body();
        start_item(xact);
        finish_item(xact);
      endtask
   endclass

   virtual function jelly_bean_transaction generic_2_bus_xact( const ref srm_generic_xact_t xact );
      jelly_bean_transaction jb_tx 
        = jelly_bean_transaction::type_id::create("jb_tx");

      if ( xact.kind == UVM_READ )       jb_tx.command = jelly_bean_types::READ;
      else if ( xact.kind == UVM_WRITE ) jb_tx.command = jelly_bean_types::WRITE;
      else                               jb_tx.command = jelly_bean_types::NO_OP;
      if ( xact.kind == UVM_WRITE )
        { jb_tx.sour, jb_tx.sugar_free, jb_tx.color, jb_tx.flavor } = xact.data[0];
      return jb_tx;
   endfunction 

   // Abstract method from base class.
   virtual task execute(ref srm_generic_xact_t generic_xact, int seq_priority);
      jelly_bean_transaction item;
      jelly_bean_adapter_sequence seq = new("jb_adapter_seq");
      
      seq.xact = generic_2_bus_xact(generic_xact);
      seq.start(_sqr, null, seq_priority);
   endtask

endclass: jelly_bean_frontdoor_adapter

