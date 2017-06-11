`ifndef INCLUDED_cpu_reg32_svh
`define INCLUDED_cpu_reg32_svh

//---------------------------------------------------------
// CLASS: cpu_reg32
// Cpu register map with a single 32b RW register.
//
// Address map starts from 32'h10000 and has a single register at 32'h100
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

  //------------------------------------------------------
  // Instantiate all the registers.
  //------------------------------------------------------
  srm_address_map cpu_map;
  r1_reg r1;

  function new(string name, srm_component parent);
    super.new(name, parent);
    r1 = new(.name("r1"), .parent(this));

    cpu_map = new(.name("cpu_map"), .base_address(64'h10000));
    cpu_map.add_node(.node(r1), .offset(64'h100));

    add_address_map(cpu_map);
  endfunction
endclass
`endif

