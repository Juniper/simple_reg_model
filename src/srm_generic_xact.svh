`ifndef INCLUDED_srm_generic_xact_svh
`define INCLUDED_srm_generic_xact_svh

//-----------------------------------------------------------------
// STRUCT: srm_generic_xact
// Generic bus xact emitted by the register model.
//
// The adapter class will translate this generic xact into design specific
// transaction.
//
// DataFormat:
// {byte_n, byte_n_1,......, byte_1, byte_0} = [msb....lsb]
//-----------------------------------------------------------------
typedef struct {
  string addr_map_name;       // Name of the address map.
  srm_access_e kind;          // Read/Write cmd.
  srm_addr_t addr;            // Byte address of the register.
  srm_data_t data;            // List of bytes to be written/read.
  srm_byte_enable_t byte_enables; // List of byte enables.
  srm_status_e status;        // Return value from agent.
} srm_generic_xact_t;


`endif
