`ifndef INCLUDED_cpu_table32_svh
`define INCLUDED_cpu_table32_svh

//---------------------------------------------------------
// CLASS: cpu_table32
// Cpu register map with tables of 10 entries.
//
// Offset:   Register
//---------------------
// 'h100     r1 with 10 entries
// 'h200     r2 with 10 entries
// 'h300     r3 with 10 entries
// 'h400     blk4
//            |
//            \/
//           'h10 --> r4 with 10 entries
//           'h40 --> r5 with 10 entries
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
  // Table with 10 entries of 4B each.
  //------------------------------------------------------
  
  class r1_reg_array extends srm_reg_array#(r1_struct_t);

    // Entry in the table.
    class r1_reg extends srm_array_entry#(r1_struct_t);
      srm_field#(bit[31:0]) field;

      function new(string name, srm_component parent, srm_addr_t index=-1, 
                                                      string reset_kind="");
        super.new(name, parent, index, reset_kind);
        field = new(.name("field"), .parent(this), .n_bits(32), .lsb_pos(0),
                  .volatile(0));
        add_field(field);
      endfunction

      virtual function r1_reg clone(srm_addr_t index);
        r1_reg obj;
        obj = new(.name($psprintf("%s_%0d", get_name(), index)),
                  .parent(_parent), .index(index), .reset_kind(get_last_reset_kind()));
        foreach(obj._fields[i])
          obj._fields[i].set_policy_map(_fields[i]);

        obj._coverage_cbs = _coverage_cbs;
        $display("\nSPS: Calling clone with %0d cbs\n\n", get_num_coverage_cbs());
        $display("SPS: NUmber of coverage cbs=%0d", obj.get_num_coverage_cbs());
        return obj;
      endfunction
    endclass
      
    function new(string name,  srm_component parent);
      r1_reg entry;
      super.new(name, parent, .num_entries(10));
      entry = new(.name("r1_reg_entry"), .parent(this));
      _prototype = entry;
    endfunction
  endclass
  
  class blk extends srm_component;
    r1_reg_array r4;
    r1_reg_array r5;

    function new(string name, srm_component parent);
      super.new(name, parent);

      r4 = new(.name("r4"),  .parent(this));
      add_child(r4);
      r4.set_offset(.addr_map_name("cpu_map"), .offset(64'h10));

      r5 = new(.name("r5"),  .parent(this));
      add_child(r5);
      r5.set_offset(.addr_map_name("cpu_map"), .offset(64'h40));
    endfunction
  endclass

  //------------------------------------------------------
  // Instantiate table.
  //------------------------------------------------------
  r1_reg_array r1;
  r1_reg_array r2;
  r1_reg_array r3;
  blk blk4;

  function new(string name, srm_component parent);
    super.new(name, parent);

    r1 = new(.name("r1"), .parent(this));
    add_child(r1);
    r1.set_offset(.addr_map_name("cpu_map"), .offset(64'h100));

    r2 = new(.name("r2"), .parent(this));
    add_child(r2);
    r2.set_offset(.addr_map_name("cpu_map"), .offset(64'h200));

    r3 = new(.name("r3"), .parent(this));
    add_child(r3);
    r3.set_offset(.addr_map_name("cpu_map"), .offset(64'h300));

    blk4 = new(.name("blk4"), .parent(this));
    add_child(blk4);
    blk4.set_offset(.addr_map_name("cpu_map"), .offset(64'h400));

  endfunction
endclass
`endif

