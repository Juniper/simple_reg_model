
//------------------------------------------------------------------------------
// Class: jelly_bean_reg_adapter
// Executes the transaction on the sequencer.
//------------------------------------------------------------------------------

class jelly_bean_reg_adapter extends srm_bus_adapter;

   jelly_bean_sequencer _sqr;

   function new( string name = "", string addr_map_name, jelly_bean_sequencer sqr );
      super.new( name, addr_map_name );
      _sqr = sqr;
   endfunction: new


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

   virtual function jelly_bean_transaction reg2bus( const ref srm_bus_xact rw );
      jelly_bean_transaction jb_tx 
        = jelly_bean_transaction::type_id::create("jb_tx");

      if ( rw.kind == UVM_READ )       jb_tx.command = jelly_bean_types::READ;
      else if ( rw.kind == UVM_WRITE ) jb_tx.command = jelly_bean_types::WRITE;
      else                             jb_tx.command = jelly_bean_types::NO_OP;
      if ( rw.kind == UVM_WRITE )
        { jb_tx.sour, jb_tx.sugar_free, jb_tx.color, jb_tx.flavor } = rw.data[0];
      return jb_tx;
   endfunction: reg2bus

   // Abstract method from base class.
   virtual task execute(ref srm_bus_xact bus_op);
      jelly_bean_transaction item;
      jelly_bean_adapter_sequence seq = new("jb_adapter_seq");
      seq.xact = reg2bus(bus_op);
      seq.start(_sqr);
   endtask

endclass: jelly_bean_reg_adapter

