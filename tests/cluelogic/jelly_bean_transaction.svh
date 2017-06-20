//------------------------------------------------------------------------------
// Class: jelly_bean_transaction
//------------------------------------------------------------------------------

class jelly_bean_transaction extends uvm_sequence_item;
   rand jelly_bean_types::flavor_e  flavor;
   rand jelly_bean_types::color_e   color;
   rand bit                         sugar_free;
   rand bit                         sour;
   rand jelly_bean_types::command_e command;
   jelly_bean_types::taste_e        taste;

   constraint flavor_color_con {
      flavor != jelly_bean_types::NO_FLAVOR;
      flavor == jelly_bean_types::APPLE     -> color != jelly_bean_types::BLUE;
      flavor == jelly_bean_types::BLUEBERRY -> color == jelly_bean_types::BLUE;
   }

   function new( string name = "" );
      super.new( name );
   endfunction: new

   `uvm_object_utils_begin( jelly_bean_transaction )
      `uvm_field_enum( jelly_bean_types::flavor_e, flavor, UVM_ALL_ON )
      `uvm_field_enum( jelly_bean_types::color_e,  color,  UVM_ALL_ON )
      `uvm_field_int ( sugar_free,   UVM_ALL_ON )
      `uvm_field_int ( sour,         UVM_ALL_ON )
      `uvm_field_enum( jelly_bean_types::command_e, command, UVM_ALL_ON )
      `uvm_field_enum( jelly_bean_types::taste_e,   taste,   UVM_ALL_ON )
   `uvm_object_utils_end
endclass: jelly_bean_transaction

//------------------------------------------------------------------------------
// Class: sugar_free_jelly_bean_transaction
//------------------------------------------------------------------------------
   
class sugar_free_jelly_bean_transaction extends jelly_bean_transaction;
   `uvm_object_utils( sugar_free_jelly_bean_transaction )

   constraint sugar_free_con {
      sugar_free == 1;
   }

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: sugar_free_jelly_bean_transaction


