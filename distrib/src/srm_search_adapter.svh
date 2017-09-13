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
`ifndef INCLUDED_srm_search_adapter_svh
`define INCLUDED_srm_search_adapter_svh

//-----------------------------------------------------------------
// CLASS: srm_search_adapter
// Select the correct bus adapter instance from the hierarchy.
//
// Walk from the leaf to the root looking for correct adapter inst. 
// Derived class must override the virtual function *is_correct_adapter*
// to select the correct instance.
//-----------------------------------------------------------------
class srm_search_adapter extends uvm_object;
  `uvm_object_utils(srm_search_adapter)

  srm_bus_adapter adapters[$];

  //------------------
  // Group: Initialization
  //-------------------
  
  // Function: new
  //
  // Create a new instance of search adapter .
  //
  // Use UVM factory to create the instance.
  function new(string name="");
    super.new(name);
  endfunction

  // Function: get_adapter
  //
  // Select the correct adapter and return it.
  //
  // Return null if no correct adapter found.
  //
  virtual function srm_bus_adapter get_adapter(srm_component obj);
    srm_component ptr = obj;
    srm_bus_adapter adapters[$];

    // Walkup from leaf to root looking for correct adapter.
    while(ptr != null) begin
      adapters = ptr.get_adapters();
      for(int i = 0; i < adapters.size(); i++) begin
        if(is_correct_adapter(adapters[i])) return adapters[i];
      end
      ptr = ptr.get_parent();
    end

    return null;
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
  
endclass

`endif
