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
`ifndef INCLUDED_srm_base_handle_svh
`define INCLUDED_srm_base_handle_svh

//-----------------------------------------------------------------
// CLASS: srm_base_handle
// Client options for configurating the access.
//-----------------------------------------------------------------

class srm_base_handle extends uvm_object;

  `uvm_object_utils(srm_base_handle)

  // Variable: priority
  // Priority of the sub sequence.
  int seq_priority;

  // Variable: addr_map_name
  // Name of the address map.
  string addr_map_name;

  // Variable: enable_functional_coverage
  // Enables functional coverage for all the access to the design.
  bit enable_functional_coverage;

  // Variable: skip_read_error_msg
  // Debug variable to switch off error messages from failing reads.
  bit skip_read_error_msg; 

  // Varaible: status
  // Status of the bus xact returned by agent.
  srm_status_e generic_xact_status;

  // Variable: error_msgs
  // List of error messages encountered so far.
  string error_msgs[$];

  //------------------
  // Group: Initialization
  //-------------------
  
  // Function: new
  //
  // Create a new instance.
  //
  // Use UVM Factory instead to create the instance.
  function new(string name="");
    super.new(name);
  endfunction

  // Function: initialize 
  //
  // Initialize the instance of base handle.
  //
  // Factory uses the default constructor.
  virtual function void initialize(string addr_map_name);
    this.addr_map_name = addr_map_name;
    this.skip_read_error_msg = 0;
    this.generic_xact_status = SRM_IS_OK;
    this.seq_priority = -1;
  endfunction

  // Function: append_error
  //
  // Append error msgs for debug later by the client.
  //
  function void append_error(string msg);
    error_msgs.push_back(msg);
  endfunction

  // Function: is_correct_adapter
  //
  // Return true for the correct adapter.
  //
  // Virtual function that must be implemented by the subclass. Returns false
  // by default.
  //
  virtual function bit is_correct_adapter(srm_bus_adapter adapter);
    return 0;
  endfunction
  
  // Function: search_backwards_for_adapter
  //
  // Walk backward to root looking for correct adapter.
  //
  // Return null if no correct adapter found.
  //
  virtual function srm_bus_adapter search_backwards_for_adapter(srm_node obj);
    srm_node ptr = obj;
    srm_bus_adapter adapters[$];

    while(ptr != null) begin
      adapters = ptr.get_adapters();
      for(int i = 0; i < adapters.size(); i++) begin
        if(is_correct_adapter(adapters[i])) return adapters[i];
      end
      ptr = ptr.get_parent();
    end

    return null;
  endfunction

  // Function: get_adapter
  //
  // Select the correct adapter and return it.
  //
  // TbConfiguraration Error is no adapter found. 
  //
  virtual function srm_bus_adapter get_adapter(srm_node obj);
    srm_bus_adapter adapter = search_backwards_for_adapter(obj);
    if(adapter == null) begin
      `uvm_fatal("TbConfigurationError", 
        $psprintf("Could not locate adapter for \"%s\" node", obj.get_full_name()));
    end
    return adapter;
  endfunction
endclass

`endif
