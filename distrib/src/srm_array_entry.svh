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
`ifndef INCLUDED_srm_array_entry_svh
`define INCLUDED_srm_array_entry_svh

//--------------------------------------------------------
// CLASS: srm_array_entry
// Models the entry of the register array.
//
// The array entry is just a specialization of the register with an 
// additional attribute "index" representing the position in the array.
// The template data must be a packed structure representing the fields
// of the register.
//--------------------------------------------------------
virtual class srm_array_entry#(type T = int) extends srm_reg#(T);
  local srm_addr_t _index;   // For address computation in array.
 
  //-------------------------------
  // Group: Initialization
  //-------------------------------

  // Function: new
  //
  // Create a new instance of the entry in the array.
  // 
  // ~parent~ represents the array to which the entry belongs.
  // ~index~ represents the position within the array.
  //
  function new(string name, srm_component parent, srm_addr_t index);
    super.new(name, parent);
    _index = index;
  endfunction
  
  //----------------------
  // Group: Address computation 
  //----------------------

  // Function: get_index
  //
  // Returns the index of the entry in array.
  //
  virtual function srm_addr_t get_index();
    return _index;
  endfunction

  // Function: get_offset
  // 
  // Return the byte offset of the entry in the array.
  //
  // Get the offset of entry 0 and then add the index*width.
  //
  virtual function srm_addr_t get_offset(string addr_map_name);
    srm_addr_t offset = _parent.get_offset(addr_map_name);
    return offset + (_index * get_width_bytes());
  endfunction

  //------------------
  // Group: Private 
  //-------------------
  // Function: clone
  //
  // Abstract method that is overwritten by the derived class.
  //
  // Should create a clone of the prototype at the specified index.
  //
  pure virtual function srm_array_entry#(T) clone(srm_addr_t index);

  // Function: initialize
  //
  // Private function to initialize the clone.
  //
  protected function void __initialize(srm_array_entry#(T) obj);
    super.__initialize(obj);
  endfunction


  
endclass

`endif
