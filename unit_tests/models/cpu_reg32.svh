`ifndef INCLUDED_cpu_reg32_svh
`define INCLUDED_cpu_reg32_svh

//---------------------------------------------------------
// CLASS: cpu_reg32
// Cpu register map with multi instances of a 32b RW register.
//
// Address map starts from 32'h10000.
// Offset:   Register
//---------------------
// 'h100     r1
// 'h200     r2
// 'h300     r3
// 'h400     blk4
//            |
//            \/
//           'h10 --> r4
//           'h20 --> r5
//---------------------------------------------------------

import srm_pkg::*;

class cpu_reg32 extends srm_component;

  //------------------------------------------------------
  // 32 Bit Register
  //------------------------------------------------------
  // Data Type
  typedef struct packed {
    bit[31:0] field;
  } r1_struct_t;

  class r1_reg extends srm_reg#(r1_struct_t);

    srm_field#(bit[31:0]) field;

    function new(string name, srm_component parent);
      super.new(name, parent);
      field = new(.name("field"), .parent(this), .n_bits(32), .lsb_pos(0),
                  .volatile(0));
      add_field(field);
    endfunction

  endclass

  class blk extends srm_component;
    r1_reg r4;
    r1_reg r5;
    function new(string name, srm_component parent);
      super.new(name, parent);
      r4 = new(.name("r4"),  .parent(this));
      add_child(r4);

      r5 = new(.name("r5"),  .parent(this));
      add_child(r5);
    endfunction
  endclass

  //------------------------------------------------------
  // Instantiate all the registers.
  //------------------------------------------------------
  srm_address_map cpu_map;
  r1_reg r1;
  r1_reg r2;
  r1_reg r3;
  blk    blk4;

  function new(string name, srm_component parent);
    super.new(name, parent);

    cpu_map = new(.name("cpu_map"), .base_address(64'h10000));

    r1 = new(.name("r1"), .parent(this));
    add_child(r1);
    cpu_map.add_node(.node(r1), .offset(64'h100));

    r2 = new(.name("r2"), .parent(this));
    add_child(r2);
    cpu_map.add_node(.node(r2), .offset(64'h200));
    
    r3 = new(.name("r3"), .parent(this));
    add_child(r3);
    cpu_map.add_node(.node(r3), .offset(64'h300));
  
    blk4 = new(.name("blk4"), .parent(this));
    add_child(blk4);
    cpu_map.add_node(.node(blk4), .offset(64'h400));
    
    cpu_map.add_node(.node(blk4.r4), .offset(64'h410));
    cpu_map.add_node(.node(blk4.r5), .offset(64'h420));

    add_address_map(cpu_map);
  endfunction
endclass
`endif

