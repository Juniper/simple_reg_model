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
`ifndef INCLUDED_srm_bus_predictor
`define INCLUDED_srm_bus_predictor

// Class: srm_bus_predictor
// Abstract base class for updating the register model with the transaction on the bus.
//
// This uvm component is used in *passive* mode where we need to update the model (say
// for coverage) due to accesses by an embedded cpu or legacy traffic. The TbWriter would
// subclass this component and provide the implementation of bus2_generic_xact. Then he/she
// would hook the output of the bus monitor to the analysis port of this component.
//
class srm_bus_predictor #(type BUSTYPE=int) extends uvm_component;

  `uvm_component_param_utils(srm_bus_predictor#(BUSTYPE))

  // Variable: bus_in
  // Observed bus transacations of type ~BUSTYPE~ are received from this
  // port and processed.
  //
  uvm_analysis_imp #(BUSTYPE, srm_bus_predictor #(BUSTYPE)) bus_in;

  // Variable: regmodel
  // This is used to update the corresponding register. Must be configured before
  // the run phase.
  srm_component regmodel;

  // Variable: addr_map_name 
  // This is used to find the corresponding register. Must be configured before
  // the run phase.
  string addr_map_name;

  // Function: new
  // Create a new instance of this type, giving the optional ~name~ and ~parent~.
  //
  function new(string name, uvm_component parent);
    super.new(name, parent);
    bus_in = new("bus_in", this);
  endfunction

  // Function: bus2reg
  // Convert the bus transacation to a generic register transaction.
  // 
  // Derived class must override this to convert bus to generic transaction.
  //
  virtual function srm_generic_xact_t bus_2_generic_xact(BUSTYPE tr);
    srm_generic_xact_t x;
    return x;
  //endfunction

  // Function: write
  // Triggered when the bus transaction appears on the analysis import *bus_in*
  //
  // Converts the bus xact to generic, extract the address and do a reverse map to find
  // the node instance. Then it updates the node with the transaction.
  //
  // If the reverse map fails then the function will raise uvm_fatal.
  //
  virtual function void write(BUSTYPE tr);
    srm_generic_xact_t xact;
    srm_component node;
    xact = bus_2_generic_xact(tr);
    node = regmodel.address_2_instance(addr_map_name, xact.addr);
    if(node == null) begin
      `uvm_fatal("TbConfigurationError", 
        $psprintf("Could not find node for address=0x%0x in address map \"%s\"", 
                                                       xact.addr, addr_map_name));
    end
    node.predictor_update(xact);
  endfunction

endclass

`endif
