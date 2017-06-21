`ifndef INCLUDED_jelly_bean_reg_block
`define INCLUDED_jelly_bean_reg_block

//------------------------------------------------------------------------------
// Class: jelly_bean_reg_block
//------------------------------------------------------------------------------
class jelly_bean_reg_block extends srm_component;

  typedef struct packed {
    bit[1:0] taste;
  } taste_t;

  class jelly_bean_taste_reg extends srm_reg#(taste_t);
    srm_field#(bit[1:0]) taste;

    function new(string name, srm_component parent);
      super.new(name, parent);
      taste = new(.name("taste"), .parent(this), .n_bits(2), .lsb_pos(0),
                  .volatile(1));
      add_field(taste);
    endfunction
  endclass

  typedef struct packed {
    bit reserved;
    bit sour;
    bit sugar_free;
    bit [1:0] color;
    bit [2:0] flavor;
  } recipe_t;

  class jelly_bean_recipe_constr extends uvm_object;
   `uvm_object_utils( jelly_bean_recipe_constr )

    rand bit[2:0] flavor;
    rand bit[1:0] color;
    rand bit sugar_free;
    rand bit sour;

    constraint flavor_color_con {
       flavor != jelly_bean_types::NO_FLAVOR;
       flavor == jelly_bean_types::APPLE
                    -> color != jelly_bean_types::BLUE;
       flavor == jelly_bean_types::BLUEBERRY
                    -> color == jelly_bean_types::BLUE;
       flavor <= jelly_bean_types::CHOCOLATE;
    }

   function new( string name = "jelly_bean_recipe_reg" );
      super.new( .name( name ));
   endfunction: new

   function recipe_t get_data();
    recipe_t d;
    d.flavor = flavor;
    d.color = color;
    d.sugar_free = sugar_free;
    d.sour = sour;
   endfunction

  endclass

  class jelly_bean_recipe_reg extends srm_reg#(recipe_t);
    srm_field#(bit) reserved;  //FIXME: have a reserved field bit.
    srm_field#(bit) sour;
    srm_field#(bit) sugar_free;
    srm_field#(bit[1:0]) color;
    srm_field#(bit[2:0]) flavor;

    function new(string name, srm_component parent);
      super.new(name, parent);
      reserved = new(.name("reserved"), .parent(this), .n_bits(1), .lsb_pos(7), .volatile(0));

      sour = new(.name("sour"), .parent(this), .n_bits(1), .lsb_pos(6), .volatile(0));
      add_field(sour);
      sour.set_reset_value(.value('h0), .kind("HARD"));

      sugar_free = new(.name("sugar_free"), .parent(this), .n_bits(1), .lsb_pos(5),
                       .volatile('b0));
      add_field(sugar_free);
      sugar_free.set_reset_value(.value('h0), .kind("HARD"));

      color = new(.name("color"), .parent(this), .n_bits(2), .lsb_pos(3), .volatile('h0));
      add_field(color);
      color.set_reset_value(.value('h0), .kind("HARD"));

      flavor = new(.name("flavor"), .parent(this), .n_bits(3), .lsb_pos(0), .volatile('h0));
      add_field(flavor);
      flavor.set_reset_value(.value('h0), .kind("HARD"));

    endfunction
  endclass

  // Instantiate the registers
  jelly_bean_recipe_reg jb_recipe_reg;
  jelly_bean_taste_reg jb_taste_reg;

  function new(string name, srm_component parent);
    super.new(name, parent);

    jb_recipe_reg = new(.name("jb_recipe_reg"), .parent(this));
    add_child(jb_recipe_reg);
    jb_recipe_reg.set_offset(.addr_map_name("reg_map"), .offset(8'h0));

    jb_taste_reg = new(.name("jb_taste_reg"), .parent(this));
    add_child(jb_taste_reg);
    jb_taste_reg.set_offset(.addr_map_name("reg_map"), .offset(8'h01));

    reset(.kind("HARD"));
   endfunction 

endclass: jelly_bean_reg_block  
`endif
