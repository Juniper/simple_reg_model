`ifndef INCLUDED_cpu_reg32_svh
`define INCLUDED_cpu_reg32_svh

//---------------------------------------------------------
// CLASS: cpu_reg32
// Cpu register map with multi instances of a 32b RW register.
//
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

class cpu_reg32 extends srm_component;

  //------------------------------------------------------
  // 32 Bit Register
  //------------------------------------------------------
  // Data Type
  typedef struct packed {
    bit[31:0] field;
  } r1_struct_t;

  // Constraint class
  class r1_constr extends uvm_object;
    `uvm_object_utils(r1_constr)
    rand bit [31:0] field;

    function new(string name="r1_constr");
      super.new(name);
    endfunction

    function r1_struct_t get_data();
      r1_struct_t d;
      d.field = field;
    endfunction
  endclass

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
      r4.set_offset("cpu_map", .offset(64'h10));

      r5 = new(.name("r5"),  .parent(this));
      add_child(r5);
      r5.set_offset("cpu_map", .offset(64'h20));

    endfunction
  endclass

  //------------------------------------------------------
  // Instantiate all the registers.
  //------------------------------------------------------
  r1_reg r1;
  r1_reg r2;
  r1_reg r3;
  blk    blk4;

  function new(string name, srm_component parent);
    super.new(name, parent);

    r1 = new(.name("r1"), .parent(this));
    add_child(r1);
    r1.set_offset("cpu_map", .offset(64'h100));

    r2 = new(.name("r2"), .parent(this));
    add_child(r2);
    r2.set_offset("cpu_map", .offset(64'h200));
    
    r3 = new(.name("r3"), .parent(this));
    add_child(r3);
    r3.set_offset("cpu_map", .offset(64'h300));
  
    blk4 = new(.name("blk4"), .parent(this));
    add_child(blk4);
    blk4.set_offset("cpu_map", .offset(64'h400));

  endfunction
endclass
`endif

