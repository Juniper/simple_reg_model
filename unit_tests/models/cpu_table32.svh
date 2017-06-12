`ifndef INCLUDED_cpu_table32_svh
`define INCLUDED_cpu_table32_svh

//---------------------------------------------------------
// CLASS: cpu_table32
// Cpu register map with a table of 10 entries.
//
// Address map starts from 32'h10000 and has a table of 10 entries start at 32'h100
//---------------------------------------------------------

import srm_pkg::*;

class cpu_table32 extends srm_component;

  //------------------------------------------------------
  // Data type for each entry in the table.
  //------------------------------------------------------
  // Data Type
  typedef struct packed {
    bit[31:0] field;
  } r1_struct_t;

  //------------------------------------------------------
  // Table with 10 entries.
  //------------------------------------------------------
  
  class r1_reg_array extends srm_reg_array#(r1_struct_t);

    // Entry in the table.
    class r1_reg extends srm_array_entry#(r1_struct_t);
      srm_field#(bit[31:0]) field;

      function new(string name, srm_component parent, srm_addr_t index);
        super.new(name, parent, index);
        field = new(.name("field"), .parent(this), .n_bits(32), .lsb_pos(0),
                  .volatile(0));
        add_field(field);
      endfunction

      virtual function r1_reg clone(srm_addr_t index);
        r1_reg obj;
        obj = new(.name($psprintf("%s_%0d", get_name(), index)),
                  .parent(_parent), .index(index));
        return obj;
      endfunction
    endclass
      
    function new(string name,  srm_component parent);
      r1_reg entry;
      super.new(name, parent, .num_entries(10));
      entry = new(.name("r1_reg_entry"), .parent(this), .index(-1));
      _prototype = entry;
    endfunction
  endclass

  //------------------------------------------------------
  // Instantiate table.
  //------------------------------------------------------
  srm_address_map cpu_map;
  r1_reg_array r1;

  function new(string name, srm_component parent);
    super.new(name, parent);
    r1 = new(.name("r1"), .parent(this));
    add_child(r1);

    cpu_map = new(.name("cpu_map"), .base_address(64'h10000));
    cpu_map.add_node(.node(r1), .offset(64'h100));

    add_address_map(cpu_map);
  endfunction
endclass
`endif

