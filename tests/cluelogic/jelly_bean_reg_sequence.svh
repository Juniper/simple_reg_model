//------------------------------------------------------------------------------
// Class: jelly_bean_reg_sequence
//------------------------------------------------------------------------------

class jelly_bean_reg_sequence extends uvm_reg_sequence;
   `uvm_object_utils( jelly_bean_reg_sequence )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual task body();
      jelly_bean_reg_block       jb_reg_block;
      jelly_bean_types::flavor_e flavor;
      jelly_bean_types::color_e  color;
      bit                        sugar_free;
      bit                        sour;
      uvm_status_e               status;
      uvm_reg_data_t             value;

      $cast( jb_reg_block, model );
      flavor     = jelly_bean_types::APPLE;
      color      = jelly_bean_types::GREEN;
      sugar_free = 0;
      sour       = 1;
      
      write_reg( jb_reg_block.jb_recipe_reg, status, { sour, sugar_free, color, flavor } );
      read_reg( jb_reg_block.jb_taste_reg, status, value );
   endtask: body
     
endclass: jelly_bean_reg_sequence


