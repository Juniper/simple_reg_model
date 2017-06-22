`ifndef INCLUDED_test_utils_sv
`define INCLUDED_test_utils_sv

import srm_pkg::*;

// A dummy adapter that remembers the last 32b of  written data.
class dummy_adapter extends srm_bus_adapter;
  reg [31:0] last_data;
  reg [31:0] bus_data;
  reg [3:0]  byte_enables;
  srm_addr_t last_addr;

  function new(string name);
    super.new(name);
  endfunction

  virtual task execute(ref srm_generic_xact_t generic_xact);
    reg[31:0]   temp;

    if(generic_xact.kind == srm_pkg::SRM_WRITE) begin
      last_data = 'd0;
      bus_data = 'd0;
      byte_enables = 'd0;
      // [31:0] = {byte3, byte2, byte1, byte0}
      for(int i = generic_xact.data.size()-1; i >= 0; i--) begin
        last_data <<= 8;
        bus_data <<= 8;
        if(generic_xact.byte_enables[i]) last_data[7:0] = generic_xact.data[i];
        bus_data[7:0] = generic_xact.data[i];
      end
      last_addr = generic_xact.addr;
    end else begin
      // CHEAT HERE: return a hardwired data instead of actually doing a wr sequence.
      temp = last_data;
      // {byte3, byte2, byte1, byte0} = [31:0]
      foreach(generic_xact.data[i]) begin
        if(generic_xact.byte_enables[i]) begin
	      generic_xact.data[i] = temp[7:0];
        end else begin
	      generic_xact.data[i] = 8'hff;
        end
        temp >>= 8;
      end
    end
    foreach(generic_xact.byte_enables[i]) begin
      byte_enables[i] = generic_xact.byte_enables[i];
    end
    generic_xact.status = srm_pkg::SRM_IS_OK;
  endtask

endclass

// Adapter policy that chooses the first adapter found.
class first_adapter_policy extends srm_adapter_policy;
  function bit is_correct_adapter(srm_bus_adapter adapter);
    return 1;
  endfunction
endclass

`endif
