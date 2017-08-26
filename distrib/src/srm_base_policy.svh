`ifndef INCLUDED_srm_base_policy_svh
`define INCLUDED_srm_base_policy_svh

typedef class srm_base_field;
virtual class srm_base_policy;

  // Function: get_name
  // Name of the policy
  pure virtual function string get_name();

  // Function: read_policy
  // Update the contents of the model due to the sideaffect of
  // doing a read from the field.
  // Returns 0 is the update to the model needs to be skippped.
  pure virtual function bit read_policy(srm_base_field field, 
                                        ref srm_data_t bytes);

  // Function : write_policy
  // Update the contents of th model due to the sideaffects of
  // doing a write to the field.
  // Returns 0 is the update to the model needs to be skippped.
  pure virtual function bit write_policy(srm_base_field field, 
                                         ref srm_data_t bytes);
endclass

`endif
