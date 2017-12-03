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
`ifndef INCLUDED_srm_base_field_policy_svh
`define INCLUDED_srm_base_field_policy_svh

typedef class srm_base_field;
//----------------------------------------------------------------
// Class: srm_base_field_policy
// Base class for access policy on a field per address map.
//
// A policy represents the update to be done to the field model when
// a read or write issued to the design.  For example a field can be 
// read_write in 'cpu_map' but read_only for 'gpu_map'.
// ReadWrite policy would imply that the write to the design or read from 
// the design from the cpu_map would update the field model. 
// A ReadOnly policy would imply that only reads from the design in gpu_map would 
// update the field model. Writes to the design field would be ignored by the model.
//
//----------------------------------------------------------------

virtual class srm_base_field_policy;

  // Function: read_policy
  // Model the affect of doing a read from the field in the design.
  //
  // Returns 0: Skip update to the field model.
  //         1: Update the field model.
  //
  pure virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);

  // Function: write_policy
  // Model the affect of doing a write to the field in the design.
  //
  // Returns 0: Skip update to the field model.
  //         1: Update the field model with data.
  //
  pure virtual function bit write_policy(srm_base_field field, 
                                         ref srm_data_t bytes);
  
  // Function: get_name
  // Name of the policy
  //
  pure virtual function string get_name();

endclass

`endif
