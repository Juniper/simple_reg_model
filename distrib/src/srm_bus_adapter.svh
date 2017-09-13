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

endclass

`endif
