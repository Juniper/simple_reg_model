//------------------------------------------------------------------------------
// Class: jelly_bean_recipe_reg
//------------------------------------------------------------------------------

class jelly_bean_recipe_reg extends uvm_reg;
   `uvm_object_utils( jelly_bean_recipe_reg )

   rand uvm_reg_field flavor;
   rand uvm_reg_field color;
   rand uvm_reg_field sugar_free;
   rand uvm_reg_field sour;

   constraint flavor_color_con {
      flavor.value != jelly_bean_types::NO_FLAVOR;
      flavor.value == jelly_bean_types::APPLE
                   -> color.value != jelly_bean_types::BLUE;
      flavor.value == jelly_bean_types::BLUEBERRY
                   -> color.value == jelly_bean_types::BLUE;
      flavor.value <= jelly_bean_types::CHOCOLATE;
   }

   function new( string name = "jelly_bean_recipe_reg" );
      super.new( .name( name ), .n_bits( 7 ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      flavor = uvm_reg_field::type_id::create( "flavor" );
      flavor.configure( .parent                 ( this ), 
                        .size                   ( 3    ), 
                        .lsb_pos                ( 0    ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 1    ), 
                        .is_rand                ( 1    ), 
                        .individually_accessible( 1    ) );

      color = uvm_reg_field::type_id::create( "color" );
      color.configure( .parent                 ( this ), 
                       .size                   ( 2    ), 
                       .lsb_pos                ( 3    ), 
                       .access                 ( "WO" ), 
                       .volatile               ( 0    ),
                       .reset                  ( 0    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 1    ) );

      sugar_free = uvm_reg_field::type_id::create( "sugar_free" );
      sugar_free.configure( .parent                 ( this ), 
                            .size                   ( 1    ), 
                            .lsb_pos                ( 5    ), 
                            .access                 ( "WO" ), 
                            .volatile               ( 0    ),
                            .reset                  ( 0    ), 
                            .has_reset              ( 1    ), 
                            .is_rand                ( 1    ), 
                            .individually_accessible( 1    ) );

      sour = uvm_reg_field::type_id::create( "sour" );
      sour.configure( .parent                 ( this ), 
                      .size                   ( 1    ), 
                      .lsb_pos                ( 6    ), 
                      .access                 ( "WO" ), 
                      .volatile               ( 0    ),
                      .reset                  ( 0    ), 
                      .has_reset              ( 1    ), 
                      .is_rand                ( 1    ), 
                      .individually_accessible( 1    ) );
   endfunction: build
endclass: jelly_bean_recipe_reg

//------------------------------------------------------------------------------
// Class: jelly_bean_taste_reg
//------------------------------------------------------------------------------

class jelly_bean_taste_reg extends uvm_reg;
   `uvm_object_utils( jelly_bean_taste_reg )

   rand uvm_reg_field taste;

   function new( string name = "jelly_bean_taste_reg" );
      super.new( .name( name ), .n_bits( 2 ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new


   virtual function void build();
      taste = uvm_reg_field::type_id::create( "taste" );
      taste.configure( .parent                 ( this ), 
                       .size                   ( 2    ), 
                       .lsb_pos                ( 0    ), 
                       .access                 ( "RO" ), 
                       .volatile               ( 1    ),
                       .reset                  ( 0    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 1    ) );
   endfunction: build
endclass: jelly_bean_taste_reg

//------------------------------------------------------------------------------
// Class: jelly_bean_reg_block
//------------------------------------------------------------------------------

class jelly_bean_reg_block extends uvm_reg_block;
   `uvm_object_utils( jelly_bean_reg_block )

   rand jelly_bean_recipe_reg jb_recipe_reg;
   rand jelly_bean_taste_reg  jb_taste_reg;
   uvm_reg_map                reg_map;

   function new( string name = "jelly_bean_reg_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      jb_recipe_reg = jelly_bean_recipe_reg::type_id::create( "jb_recipe_reg" );
      jb_recipe_reg.configure( .blk_parent( this ) );
      jb_recipe_reg.build();

      jb_taste_reg = jelly_bean_taste_reg::type_id::create( "jb_taste_reg" );
      jb_taste_reg.configure( .blk_parent( this ) );
      jb_taste_reg.build();

      reg_map = create_map( .name( "reg_map" ), .base_addr( 8'h00 ), 
                            .n_bytes( 1 ), .endian( UVM_LITTLE_ENDIAN ) );
      reg_map.add_reg( .rg( jb_recipe_reg ), .offset( 8'h00 ), .rights( "WO" ) );
      reg_map.add_reg( .rg( jb_taste_reg  ), .offset( 8'h01 ), .rights( "RO" ) );
      lock_model(); // finalize the address mapping
   endfunction: build

endclass: jelly_bean_reg_block   

