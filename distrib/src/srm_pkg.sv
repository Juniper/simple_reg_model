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
`ifndef INCLUDED_srm_pkg_sv
`define INCLUDED_srm_pkg_sv

`include "uvm_macros.svh"

package srm_pkg;
  import uvm_pkg::*;
  typedef longint srm_addr_t;  
  typedef srm_addr_t srm_addr_lst_t[];
  typedef byte srm_data_t[];
  typedef bit srm_byte_enable_t[];

  typedef enum {
    SRM_READ,
    SRM_WRITE
  } srm_access_e;

  typedef enum {
    SRM_IS_OK,
    SRM_NOT_OK,
    SRM_READ_DATA_MISMATCH,
    SRM_HAS_X
  } srm_status_e;

  typedef enum {
    SRM_NO_HIER,
    SRM_HIER
  } srm_hier_e;

  `include "common/srm_utils.svh"
  `include "bus/srm_generic_xact.svh"
  `include "bus/srm_bus_adapter.svh"
  `include "bus/srm_bus_predictor.svh"
  `include "base/srm_base_field_policy.svh"
  `include "base/srm_base_field.svh"
  `include "base/srm_field.svh"
  `include "base/srm_field_policies.svh"
  `include "base/srm_base_coverage.svh"
  `include "base/srm_base_handle.svh"
  `include "base/srm_node.svh"
  `include "base/srm_base_reg.svh"
  `include "base/srm_reg.svh"
  `include "base/srm_table_entry.svh"
  `include "base/srm_table.svh"
endpackage

`endif
