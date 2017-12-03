`ifndef INCLUDED_CPU_TOP_SVH
`define INCLUDED_CPU_TOP_SVH

//---------------------------------------------------
// CLASS: cpu_top
// Include the 2 submaps.
// Offset    Register
// 'h0       cpu_reg32
// 'h1000    cpu_table32
//---------------------------------------------------

class cpu_top extends srm_component;

 cpu_reg32 cpu_reg32;
 cpu_table32 cpu_table32;

 function new(string name, srm_component parent);
  super.new(name, parent);

  cpu_reg32 = new(.name("cpu_reg32"), .parent(this));
  add_child(cpu_reg32);
  cpu_reg32.set_offset(.addr_map_name("cpu_map"), .offset('h0));

  cpu_table32 = new(.name("cpu_table32"), .parent(this));
  add_child(cpu_table32);
  cpu_table32.set_offset(.addr_map_name("cpu_map"), .offset('h1000));

 endfunction
endclass

`endif
