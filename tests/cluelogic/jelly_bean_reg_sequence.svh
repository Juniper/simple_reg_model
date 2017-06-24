//------------------------------------------------------------------------------
// Class: jelly_bean_reg_sequence
// This is a virtual sequence that will use the regmodel to do the xacts.
//------------------------------------------------------------------------------

class jelly_bean_reg_sequence extends uvm_sequence#(uvm_sequence_item);
   `uvm_object_utils( jelly_bean_reg_sequence )

   jelly_bean_reg_block       jb_reg_block;
   srm_base_handle            handle;

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual task body();
      jelly_bean_reg_block::taste_t rd_data;
      jelly_bean_reg_block::recipe_t wr_data;

      wr_data.flavor     = jelly_bean_types::APPLE;
      wr_data.color      = jelly_bean_types::GREEN;
      wr_data.sugar_free = 0;
      wr_data.sour       = 1;
   
      jb_reg_block.jb_recipe_reg.write(handle, wr_data);
      jb_reg_block.jb_taste_reg.read(handle, rd_data);
   endtask: body
     
endclass: jelly_bean_reg_sequence


