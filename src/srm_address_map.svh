`ifndef INCLUDED_srm_address_map_sv
`define INCLUDED_srm_address_map_sv

typedef class srm_component;
typedef class srm_base_field;

//-----------------------------------------------------------------
// CLASS: srm_address_map
// Software byte addressable address space.
//
// Each physical interface must have at least 1 address map.
//-----------------------------------------------------------------
class srm_address_map;
  string name;
  srm_addr_t base_address;

  typedef struct {
    srm_addr_t offset;
  } info_t;

  info_t offset_table[srm_component];
  string policies[srm_base_field];

  //--------------------------
  // Group: Initialization
  //--------------------------

  // Function: new
  // Create a new address map with specified starting base address.
  //
  function new(string name, srm_addr_t base_address=0);
    this.name = name;
    this.base_address = base_address;
  endfunction

  //--------------------------
  // Group: Get 
  //--------------------------
  
  // Function: get_name
  // Return the name of the addr map.
  //
  function string get_name();
    return name;
  endfunction

  // Function: get_base_address
  //
  // Return the base address of the node.
  //
  function srm_addr_t get_base_address(srm_component node);
    info_t info;
    info = offset_table[node];
    return base_address + info.offset;
  endfunction

  //--------------------------
  // Group: Add
  //--------------------------
 
  // Function: add_node
  // Add a node to the map at the specified offset.
  //
  function void add_node(srm_component node, srm_addr_t offset);
    info_t info;
    info.offset = offset; 
    offset_table[node] = info;
  endfunction

  // Function: add_submap
  // Add a submap to the map.
  //
  // This is used when top level test bench wants to leverage the address map of a lower
  // level block. All the entries from the submap are blindly added to the current map.
  function void add_submap(srm_address_map submap);
    foreach(submap.offset_table[i]) begin
      offset_table[i]  = submap.offset_table[i];
    end
  endfunction

  // Function: add_field_policy
  // Add policy name for a field in the address.
  //
  // The name of the policy must match what is present in the <srm_access_policy_map.get_policy> .
  // Policies are defined on address map since a register can be writable by one address map and
  // read only by the other address map.
  function void add_field_policy(srm_base_field field, string policy_name);
    policies[field] = policy_name;
  endfunction

endclass
`endif
