`ifndef INCLUDED_srm_base_handle_svh
`define INCLUDED_srm_base_handle_svh

typedef class srm_adapter_policy;
//-----------------------------------------------------------------
// CLASS: srm_base_handle
// Client options for configurating the access.
//-----------------------------------------------------------------

class srm_base_handle extends uvm_object;

  `uvm_object_utils(srm_base_handle)

  // Variable: priority
  // Priority of the sub sequence.
  int seq_priority;

  // Variable: adapter_policy
  // Pointer to the adapter policy to use.
  srm_adapter_policy adapter_policy;

  // Variable: addr_map_name
  // Name of the address map.
  string addr_map_name;

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
  function new(string name="");
    super.new(name);
  endfunction

  // Function: initialize 
  virtual function void initialize(srm_adapter_policy adapter_policy, string addr_map_name);
    this.adapter_policy = adapter_policy;
    this.addr_map_name = addr_map_name;
    this.skip_read_error_msg = 0;
    this.generic_xact_status = SRM_IS_OK;
    this.seq_priority = -1;
  endfunction

  // Function: append_error
  // Append error msgs for debug later by the client.
  //
  function void append_error(string msg);
    error_msgs.push_back(msg);
  endfunction

endclass

`endif
