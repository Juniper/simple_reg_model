//
// --------------------------------------------------------------
// Copyright (c) 2017-2023, Juniper Networks, Inc.
// All rights reserved.
//
// This code is licensed to you under the MIT license. 
// You many not use this code except in compliance with this license.
// This code is not an official Juniper product. You may obtain a copy
// of the license at 
//
// https://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is  distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR  CONDITIONS OF ANY KIND, either express or 
// implied.  See the License for the specific language governing
// permissions and limitations under the License.
// -------------------------------------------------------------
//
`ifndef INCLUDED_srm_bus_adapter_svh
`define INCLUDED_srm_bus_adapter_svh

//-----------------------------------------------------------------
// CLASS: srm_bus_adapter
// Abstract base class for bus adapter.
//
// Derived class must override the execute method to convert the generic
// bus operation to a design specific transaction.
//-----------------------------------------------------------------
class srm_bus_adapter extends uvm_object;

  `uvm_object_utils(srm_bus_adapter)

  //------------------
  // Group: Initialization
  //-------------------
  
  // Function: new
  //
  // Create a new instance of a register.
  //
  // Use uvm factory to create the instance of the adapter.
  //
  function new(string name="");
    super.new(name);
  endfunction

  // Task: execute
  //
  // Execute the generic bus transaction on the actual bus.
  //
  // ~generic_xact~ is the generic transaction emitted by the register model.
  //
  // ~seq_priority~ is the priority of the sequence generating the transaction.
  //
  // This is a virtual task that must be implemented by the subclass.
  //
  virtual task execute(ref srm_generic_xact_t generic_xact, int seq_priority);
  endtask

  // Function: generic_xact_to_hdl_data
  //
  // Converts the byte array from generic xact to uvm_hdl_data_t type.
  //
  // ~generic_xact~ is the generic transaction emitted by the register model.
  //
  // Returns the uvm_hdl_data_t
  //
  function uvm_hdl_data_t generic_xact_to_hdl_data(ref srm_generic_xact_t generic_xact);
    uvm_hdl_data_t hdl_data = 'd0;
    // [31:0] = {byte3, byte2, byte1, byte0}
    for(int i = generic_xact.data.size()-1; i >= 0; i--) begin
      hdl_data <<= 8;
      hdl_data[7:0] = generic_xact.data[i];
    end
    return hdl_data;
  endfunction

  // Function: hdl_data_to_generic_xact
  //
  // Converts the hdl data type to byte array inside the generic xact.
  //
  // ~generic_xact~ is the generic transaction that will be updated.
  //
  // ~hdl_data~ is the incoming data reg.
  //
  function hdl_data_to_generic_xact(ref srm_generic_xact_t generic_xact, uvm_hdl_data_t hdl_data);
    foreach(generic_xact.data[i]) begin
      generic_xact.data[i] = hdl_data[7:0];
      hdl_data >>= 8;
    end
  endfunction

endclass

`endif
