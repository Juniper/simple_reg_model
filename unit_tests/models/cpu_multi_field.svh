`ifndef INCLUDED_cpu_multi_field_svh
`define INCLUDED_cpu_multi_field_svh

//----------------------------------------------------------------
// CLASS: cpu_multi_field
// Cpu register and tables with fields.
//
// Offset:   Register
//--------------------
// 'h100 :   r1: 32b. Each byte is a field.
// 'h200 :   r2: 8b multi bit field table with 100 entries. 
//----------------------------------------------------------------

import srm_pkg::*;

class cpu_multi_field extends srm_component;

  typedef struct packed {
    bit[7:0] f3;
    bit[7:0] f2;
    bit[7:0] f1;
    bit[7:0] f0;
  } r1_struct_t;

  // Define a register with the fields.
  class r1_reg extends srm_reg#(r1_struct_t);
    
    srm_field#(bit[7:0]) f0;
    srm_field#(bit[7:0]) f1;
    srm_field#(bit[7:0]) f2;
    srm_field#(bit[7:0]) f3;

    function new(string name, srm_component parent);
      super.new(name, parent);

      // If resettable register then all fields must be resettable.
      set_reset_kind("BIST");
      set_reset_kind("HARD");

      // 2 types of reset kind. Specify the values for all the fields.
      f0 = new(.name("f0"), .parent(this), .n_bits(8), .lsb_pos(0),
               .volatile(0));
      add_field(f0);
      f0.set_reset_value(.value(8'hef), .kind("BIST"));
      f0.set_reset_value(.value(8'h67), .kind("HARD"));
      
      f1 = new(.name("f1"), .parent(this), .n_bits(8), .lsb_pos(8),
               .volatile(0));
      add_field(f1);
      f1.set_reset_value(.value(8'hcd), .kind("BIST"));
      f1.set_reset_value(.value(8'h45), .kind("HARD"));

      f2 = new(.name("f2"), .parent(this), .n_bits(8), .lsb_pos(16),
               .volatile(0));
      add_field(f2);
      f2.set_reset_value(.value(8'hab), .kind("BIST"));
      f2.set_reset_value(.value(8'h23), .kind("HARD"));

      f3 = new(.name("f3"), .parent(this), .n_bits(8), .lsb_pos(24),
               .volatile(0));
      add_field(f3);
      f3.set_reset_value(.value(8'h89), .kind("BIST"));
      f3.set_reset_value(.value(8'h01), .kind("HARD"));

    endfunction
  endclass

  // Define a table with 1 byte data and arbitary bit fields.
  typedef struct packed {
    bit      f4;
    bit      f3;
    bit[2:0] f2;
    bit[1:0] f1;
    bit      f0;
  } r2_struct_t;

  class r2_table extends srm_reg_array#(r2_struct_t);

    // Entry of the table.
    class r2_entry extends srm_array_entry#(r2_struct_t);
      srm_field#(bit) f4;
      srm_field#(bit) f3;
      srm_field#(bit[2:0]) f2;
      srm_field#(bit[1:0]) f1;
      srm_field#(bit) f0;

      function new(string name, srm_component parent, srm_addr_t index=-1);
        super.new(name, parent, index);
        // If resettable, then all fields must be resettable and value defined.
        set_reset_kind("HARD");
        set_reset_kind("BIST");

        f0 = new(.name("f0"), .parent(this), .n_bits(1), .lsb_pos(0), .volatile(0));
        add_field(f0);
        f0.set_reset_value(.value(0), .kind("HARD"));
        f0.set_reset_value(.value(1), .kind("BIST"));

        f1 = new(.name("f1"), .parent(this), .n_bits(2), .lsb_pos(1), .volatile(0));
        add_field(f1);
        f1.set_reset_value(.value('h0), .kind("HARD"));
        f1.set_reset_value(.value('h3), .kind("BIST"));

        f2 = new(.name("f2"), .parent(this), .n_bits(3), .lsb_pos(3), .volatile(0));
        add_field(f2);
        f2.set_reset_value(.value('h0), .kind("HARD"));
        f2.set_reset_value(.value('h7), .kind("BIST"));

        f3 = new(.name("f3"), .parent(this), .n_bits(1), .lsb_pos(6), .volatile(0));
        add_field(f3);
        f3.set_reset_value(.value('h0), .kind("HARD"));
        f3.set_reset_value(.value('h1), .kind("BIST"));

        f4 = new(.name("f4"), .parent(this), .n_bits(1), .lsb_pos(7), .volatile(0));
        add_field(f4);
        f4.set_reset_value(.value('h0), .kind("HARD"));
        f4.set_reset_value(.value('h1), .kind("BIST"));
      
      endfunction


      virtual function r2_entry clone(srm_addr_t index);
        r2_entry obj;
        obj = new(.name($psprintf("%s_%0d", get_name(), index)),
                  .parent(_parent), .index(index));
        __initialize(obj);
        return obj;
      endfunction
    endclass

    // Table definition
    function new(string name, srm_component parent);
      r2_entry entry;
      super.new(name, parent, .num_entries(100));
      entry = new(.name("r2_entry"), .parent(this));
      _prototype = entry;
    endfunction

    // Convienence
    virtual function r2_entry entry_at(srm_addr_t index);
      r2_entry entry;
      $cast(entry, super.entry_at(index));
      return entry;
    endfunction
  endclass

  // Instantiate all the registers and tables.
  r1_reg r1;
  r2_table r2;

  function new(string name, srm_component parent);
    super.new(name, parent);

    r1= new(.name("r1"), .parent(this)); 
    add_child(r1);
    r1.set_offset(.addr_map_name("cpu_map"), .offset('h100));

    r2 = new(.name("r2"), .parent(this));
    add_child(r2);
    r2.set_offset(.addr_map_name("cpu_map"), .offset('h200));

    // Reset the contents of the entire register model at start.
    reset(.kind("HARD"));
  endfunction

endclass
`endif
  
