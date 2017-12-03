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

typedef class srm_search_adapter;
//-----------------------------------------------------------------
// CLASS: srm_base_handle
// Client options for configurating the access.
//-----------------------------------------------------------------

class srm_base_handle extends uvm_object;

  `uvm_object_utils(srm_base_handle)

  // Variable: priority
  // Priority of the sub sequence.
  int seq_priority;

  // Variable: search_adapter 
  // Pointer to the adapter instance search logic.
  srm_search_adapter search_adapter;

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
  virtual function void initialize(srm_search_adapter search_adapter, string addr_map_name);
    this.search_adapter = search_adapter;
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

endclass

`endif
