`ifndef INCLUDED_test_utils_sv
`define INCLUDED_test_utils_sv

import srm_pkg::*;

// A dummy adapter that remembers the last 32b of  written data.
class dummy_adapter extends srm_bus_adapter;
  reg [31:0] last_data;
  reg [31:0] bus_data;
  reg [3:0]  byte_enables;
  srm_addr_t last_addr;

  function new(string addr_map_name); 
    super.new(.addr_map_name(addr_map_name), .name("dummy_adapter")); 
  endfunction

  virtual task execute(ref srm_bus_xact bus_op);
    reg[31:0]   temp;

    if(bus_op.kind == srm_pkg::SRM_WRITE) begin
      last_data = 'd0;
      bus_data = 'd0;
      byte_enables = 'd0;
      // [31:0] = {byte3, byte2, byte1, byte0}
      for(int i = bus_op.data.size()-1; i >= 0; i--) begin
        last_data <<= 8;
        bus_data <<= 8;
        if(bus_op.byte_enables[i]) last_data[7:0] = bus_op.data[i];
        bus_data[7:0] = bus_op.data[i];
      end
      last_addr = bus_op.addr;
    end else begin
      // CHEAT HERE: return a hardwired data instead of actually doing a wr sequence.
      temp = last_data;
      // {byte3, byte2, byte1, byte0} = [31:0]
      foreach(bus_op.data[i]) begin
        bus_op.data[i] = temp[7:0];
        temp >>= 8;
      end
    end
    foreach(bus_op.byte_enables[i]) begin
      byte_enables[i] = bus_op.byte_enables[i];
    end
    bus_op.status = srm_pkg::SRM_IS_OK;
  endtask

endclass

// Adapter policy that chooses the first adapter found.
class first_adapter_policy extends srm_adapter_policy;
  function bit is_correct_adapter(srm_bus_adapter adapter);
    return 1;
  endfunction
endclass

`endif
