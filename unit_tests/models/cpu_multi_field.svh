`ifndef INCLUDED_cpu_multi_field_svh
`define INCLUDED_cpu_multi_field_svh

//----------------------------------------------------------------
// CLASS: cpu_multi_field
// Cpu register and tables with fields.
//
// Offset:   Register
//--------------------
// 'h100 :   r1: 64b. Each bit is a field.
// 'h200 :   r2: table with 100 entries. 
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

      f0 = new(.name("f0"), .parent(this), .n_bits(8), .lsb_pos(0),
               .volatile(0));
      add_field(f0);

      f1 = new(.name("f1"), .parent(this), .n_bits(8), .lsb_pos(8),
               .volatile(0));
      add_field(f1);

      f2 = new(.name("f2"), .parent(this), .n_bits(8), .lsb_pos(16),
               .volatile(0));
      add_field(f2);

      f3 = new(.name("f3"), .parent(this), .n_bits(8), .lsb_pos(24),
               .volatile(0));
      add_field(f3);
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

      function new(string name, srm_component parent, srm_addr_t index);
        super.new(name, parent, index);
        f0 = new(.name("f0"), .parent(this), .n_bits(1), .lsb_pos(0), .volatile(0));
        add_field(f0);
        f1 = new(.name("f1"), .parent(this), .n_bits(2), .lsb_pos(1), .volatile(0));
        add_field(f1);
        f2 = new(.name("f2"), .parent(this), .n_bits(3), .lsb_pos(3), .volatile(0));
        add_field(f2);
        f3 = new(.name("f3"), .parent(this), .n_bits(1), .lsb_pos(6), .volatile(0));
        add_field(f3);
        f4 = new(.name("f4"), .parent(this), .n_bits(1), .lsb_pos(7), .volatile(0));
        add_field(f4);
      endfunction

      virtual function r2_entry clone(srm_addr_t index);
        r2_entry obj;
        obj = new(.name($psprintf("%s_%0d", get_name(), index)),
                  .parent(this), .index(index));
        return obj;
      endfunction
    endclass

    // Table definition
    function new(string name, srm_component parent);
      r2_entry entry;
      super.new(name, parent, .num_entries(100));
      entry = new(.name("r2_entry"), .parent(this), .index(-1));
      _prototype = entry;
    endfunction

    //-----------------------
    // Composite 
    //-----------------------
    function r2_entry entry_at(srm_addr_t index);
      string name;
      srm_array_entry#(r2_struct_t) entry;
      r2_entry e;
      entry = super.entry_at(index);
      // NCsim does not like me returning r2_entry directly.
      $cast(e, entry);
      return e;
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
  endfunction

endclass
`endif
  