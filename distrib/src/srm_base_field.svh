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
`ifndef INCLUDED_srm_base_field_svh
`define INCLUDED_srm_base_field_svh

//------------------------------------------------------
// CLASS: srm_base_field
// Base class for a field in a register.
//
// A field is a contingous set of bits accessed indivisibly by sw. This
// base class keeps the size in bits and the access policy of the field.
// This is a base class and should not be used directly by the user.
//
//------------------------------------------------------
virtual class srm_base_field;
  local string _name;
  protected srm_base_reg _parent;
  protected int _n_bits;
  protected int _lsb_pos;

  local bit _volatile;
  protected srm_base_field_policy _policy_map[string];

  //-----------------
  // Group: Initialization
  //-----------------
  
  // Function: new
  //
  // Create a new base field instance.
  //
  // ~parent~ represents the register to which the field belongs.
  // ~n_bits~ represents the size of the field in bits.
  // ~lsb_pos~ represents the least significant position of the field.
  // ~volatile~ represents whether the field is volatile ie modified by design.
  //
  function new(string name, srm_base_reg parent, int n_bits, int lsb_pos,
               bit volatile);
    _name = name;
    _parent = parent;
    _n_bits = n_bits;
    _lsb_pos = lsb_pos;
    _volatile = volatile;
  endfunction

  //-----------------
  // Group: Introspection 
  //-----------------
  
  // Function: get_name
  //
  // Return the name of the field.
  //
  function string get_name();
    return _name;
  endfunction

  // Function: get_full_name
  //
  // Return the full hierarichal name of the field.
  //
  // This returns the path starting with the root node of the design hierarchy.
  //
  function string get_full_name();
    return {_parent.get_full_name(), ".", _name};
  endfunction

  // Function: get_parent
  //
  // Return the pointer to the register to which the field belongs.
  //
  function srm_base_reg get_parent();
    return _parent;
  endfunction

  // Function: get_n_bits
  //
  // Return the size of the field in bits.
  //
  function int get_n_bits();
    return _n_bits;
  endfunction

  // Function: get_lsb_pos
  //
  // Return the lsb of the field in the register.
  //
  function int get_lsb_pos();
    return _lsb_pos;
  endfunction

  // Function: is_volatile
  //
  // Returns true if the field is volatile.
  //
  // A field written by design. These values cannot be predicted by the model
  // and so are skipped during checking.
  //
  function bit is_volatile();
    return _volatile;
  endfunction

  //-------------------
  // Group: Access
  //-------------------

  // Function: get_bytes
  //
  // Virtual function that will be implemented by srm_field.
  //
  // A field is a template class. This function converts the template data into
  // a list of bytes so that I can treat them in a generic way.
  //
  pure virtual function srm_data_t get_bytes();

  // Function: set_bytes
  //
  // Virtual function that will be implemented by srm_field.
  //
  // This function converts the list of bytes into the template parameter of the
  // field class.
  //
  pure virtual function void set_bytes(const ref srm_data_t bytes);

  //-----------------
  // Group: Field Policy 
  //-----------------
  // Function: set_policy
  //
  // Set policy of a field as per address map.
  //
  // ~addr_map_name~ represents the address map.
  //
  // ~policy~ represents the access policy.
  //
  // A field may have different policy (like read_write, read_only) as per the address
  // map.
  //
  virtual function void set_policy(string addr_map_name, srm_base_field_policy policy);
    _policy_map[addr_map_name] = policy;
  endfunction

  // Function: get_policy
  //
  // Return the policy for the address map. 
  //
  // ~addr_map_name~ represents the address map.
  virtual function srm_base_field_policy get_policy(string addr_map_name);
    srm_base_field_policy p =  _policy_map[addr_map_name];
    if(p == null) begin
      p = srm_rw_policy::get();
    end
    return p;
  endfunction


  //-------------------------------------
  // Group: Private
  //-------------------------------------

  // Function: reset
  //
  // Virtual function implemented by subclass to reset the field.
  //
  // ~kind~ represents the type of reset. A field can have multiple
  // reset values depending on the type of reset.
  //
  virtual function void reset(string kind);
  endfunction

  // Function: __initialize
  // 
  // Initialize the state from the current value.
  //
  // Used by the framework to create a clone for new entry in the register array.
  //
  virtual function void __initialize(srm_base_field obj);
    _policy_map = obj._policy_map;
  endfunction
endclass

`endif
