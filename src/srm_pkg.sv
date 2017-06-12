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

  `include "srm_utils.svh"
  `include "srm_bus_xact.svh"
  `include "srm_handle.svh"
  `include "srm_bus_adapter.svh"
  `include "srm_address_map.svh"
  `include "srm_component.svh"
  `include "srm_adapter_policy.svh"
  `include "srm_base_reg.svh"
  `include "srm_base_field.svh"
  `include "srm_field.svh"
  `include "srm_reg.svh"
  `include "srm_array_entry.svh"
  `include "srm_reg_array.svh"
endpackage

`endif
