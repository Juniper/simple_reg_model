//------------------------------------------------------------------------------
// Class: jelly_bean_backdoor_adapter
// Executes the transaction on the sequencer.
//------------------------------------------------------------------------------

class jelly_bean_backdoor_adapter extends srm_bus_adapter;

   `uvm_object_utils(jelly_bean_backdoor_adapter)

   function new(string name = "");
      super.new(name);
   endfunction: new

   // Abstract method from base class.
   virtual task execute(ref srm_generic_xact_t generic_xact, int seq_priority);
    bit[1:0] taste;
    bit[7:0] data;
    if(generic_xact.kind == srm_pkg::SRM_READ) begin
      if(uvm_hdl_read("top.dut.taste", taste) == 0) begin
        `uvm_fatal("TbConfigurationError", "Could not read the backdoor path \"top.dut.taste\"");
      end
      generic_xact.data[0] = {6'd0, taste};
      $display(">>>BackdoorRead from taste register=0x%0x", generic_xact.data[0]);
    end
    else begin
      data = generic_xact.data[0];
      assert(uvm_hdl_deposit("top.dut.sour", data[6]));
      assert(uvm_hdl_deposit("top.dut.sugar_free", data[5]));
      assert(uvm_hdl_deposit("top.dut.color", data[4:3]));
      assert(uvm_hdl_deposit("top.dut.flavor", data[2:0]));
      $display(">>>BackdoorWrite to recipe register=0x%0x", data);
    end

   endtask

endclass: jelly_bean_backdoor_adapter

