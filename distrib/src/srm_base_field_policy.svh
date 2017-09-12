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
// Base class for access policy.
//
// A field has different policies for each address map.
//----------------------------------------------------------------
virtual class srm_base_field_policy;

  // Function: get_name
  // Name of the policy
  //
  pure virtual function string get_name();

  // Function: read_policy
  // Update the contents of the model due to the sideaffect of
  // doing a read from the field.
  //
  // Returns 0 is the update to the model needs to be skippped.
  //
  pure virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);

  // Function : write_policy
  // Update the contents of th model due to the sideaffects of
  // doing a write to the field.
  //
  // Returns 0 is the update to the model needs to be skippped.
  //
  pure virtual function bit write_policy(srm_base_field field, 
                                         ref srm_data_t bytes);
endclass

`endif
