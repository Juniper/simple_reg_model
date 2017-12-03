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
`ifndef INCLUDED_srm_base_coverage
`define INCLUDED_srm_base_coverage

typedef class srm_base_reg;

// -------------------------------------------------------------
// CLASS: srm_base_coverage
// Base class for coverage model.
//
// User coverage model must derive from this base class and install
// it at any level of the design hierarchy.
// -------------------------------------------------------------
class srm_base_coverage;
  string _name;

  //----------------------
  // Group: Initialization
  //----------------------

  // Function: new
  // Create a new instance with the name.
  //
  function new(string name);
    _name = name;
  endfunction

  // Function: get_name
  // Get the name of the object.
  //
  virtual function get_name();
    return _name;
  endfunction

  // Function: post_write
  // This will get called at the end of write task for the attached
  // nodes.
  //
  virtual function void post_write(srm_base_reg entry); 
    // Add code for fcov of writes.
  endfunction

  // Function: post_read
  // This will get called at the end of read task for the attached
  // nodes.
  //
  virtual function void post_read(srm_base_reg entry); 
    // Add code for fcov of reads.
  endfunction

  // Function: sample_xact
  // FIXME: only see it in write but not in read.
  virtual function void sample_xact(const ref srm_generic_xact_t xact);
    // Add code for fcov of xact.
  endfunction

endclass

`endif
