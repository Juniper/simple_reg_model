`ifndef INCLUDED_srm_component_svh
`define INCLUDED_srm_component_svh

typedef class srm_handle;
typedef srm_bus_adapter srm_adapters_t[$];

//------------------------------------------------------------
// CLASS: srm_component
// A node in the tree hierarchy.
//
//------------------------------------------------------------
class srm_component;
  local string _name;
  local srm_component _parent;
  local srm_component _children[$];
  local srm_address_map _maps[string];
  local srm_adapters_t _adapters;

  //---------------------
  // Group: Initialization
  //---------------------

  // Function: new
  function new(string name, srm_component parent);
    _name = name;
    _parent = parent;
  endfunction

  //----------------------
  // Group: Introspection
  //----------------------
 
  // Function: get_parent
  function srm_component get_parent();
    return _parent;
  endfunction

  // Function: get_name
  // Return the name of the node.
  function string get_name();
    return _name;
  endfunction

  // Function: get_full_name
  // Return the full hierarical path of the node.
  //
  function string get_full_name();
    string name_lst[$];
    string full_name = "";
    srm_component curr = this;

    while(!curr.is_root_node()) begin
      name_lst.push_front(curr.get_name());
      curr = curr._parent;
    end

    name_lst.push_front(curr.get_name());

    foreach(name_lst[i]) begin
      if(full_name == "")
        full_name = name_lst[i];
      else
        full_name = {full_name, ".", name_lst[i]};
    end

    return full_name;
  endfunction

  //----------------------
  // Group: Tree traversal
  //----------------------

  // Function: is_leaf_node
  function bit is_leaf_node();
    return (_children.size() == 0);
  endfunction

  // Function: is_root_node
  function bit is_root_node();
    return (_parent == null);
  endfunction

  // Function: add_child
  // Add a child below itself.
  function void add_child(srm_component child);
    _children.push_back(child);
  endfunction

  // Function: get_root_node
  function srm_component get_root_node();
    srm_component ptr = this;
    while(!ptr.is_root_node()) ptr = ptr._parent;
    return ptr;
  endfunction

  // Function: get_leaf_nodes
  // Recursively find all the leaf nodes below itself.
  //
  function void get_leaf_nodes(ref srm_component leaves[$]);
    if(is_leaf_node()) begin
      leaves.push_back(this);
    end else begin
      foreach(_children[i]) begin
        _children[i].get_leaf_nodes(leaves);
      end
    end
  endfunction

  function srm_component find_node_by_name(string full_name);
    srm_component p = null;
    if (full_name == get_full_name()) begin 
      return  this;
    end else begin
      foreach(_children[i]) begin
        p = _children[i].find_node_by_name(full_name);
      end
    end
    return p;
  endfunction

  //----------------------
  // Group: Address computation 
  //----------------------

  // Function: add_address_map
  // Add a unique address map for each sw entity.
  //
  function void add_address_map(srm_address_map addr_map);
    string n = addr_map.get_name();
    _maps[n] = addr_map;
  endfunction

  // Function: get_address_map
  // Return the address map given the name.
  //
  // Address map must exist otherwise fatal error.
  function srm_address_map get_address_map(string addr_map_name);
    if(_maps.exists(addr_map_name))
      return _maps[addr_map_name];
    else begin
      `uvm_fatal("TbConfigurationError", $psprintf("Could not find addr map \"%s\" in tree",
                  addr_map_name));
    end
  endfunction

  // Function: get_address
  // Return the base address of the node.
  //
  // The root node maintains all the address map. Lookup the address
  // map based on name as key and return the base address of node.
  function srm_addr_t get_address(string addr_map_name);
    string key;
    srm_address_map addr_map;
    srm_component root = get_root_node();

    addr_map = root.get_address_map(addr_map_name);
    return addr_map.get_base_address(this);
  endfunction
  
  //----------------------
  // Group: Adapter Management 
  //----------------------
  // Function: add_adapter
  // Add the adapter to the list.
  //
  // Each node maintains a list of adapters.
  function void add_adapter(srm_bus_adapter adapter);
    _adapters.push_back(adapter);
  endfunction

  // Function: get_adapters
  // Return the list of adapters at this node.
  //
  function srm_adapters_t get_adapters();
    return _adapters;
  endfunction


  //----------------------
  // Group: Composite Commands 
  //----------------------

  // Task: load
  // Call load on all the leaf nodes of the tree.
  //
  virtual task load(srm_handle handle);
    srm_component leaves[$];

    get_leaf_nodes(leaves);

    foreach(leaves[i]) begin
      leaves[i].load(handle);
    end

  endtask

  // Task: store 
  // Call store on all the leaf nodes of the tree.
  //
  virtual task store(srm_handle handle);
    srm_component leaves[$];

    get_leaf_nodes(leaves);

    foreach(leaves[i]) begin
      leaves[i].store(handle);
    end

  endtask


  // Task: store_update 
  // Call store_update on all the children of the node.
  //
  virtual task store_update(srm_handle handle, const ref srm_component node, 
                            bit skip_duplicate);
    srm_component next_node;

    foreach(_children[i]) begin
      next_node = find_node_by_name(_children[i].get_full_name());
      if(next_node == null) begin
        `uvm_fatal("TbConfiguraionError", $psprintf("Could not find node \"%s\" in tree",
          _children[i].get_full_name()));
      end else begin
        _children[i].store_update(handle, next_node, skip_duplicate);
      end
    end

  endtask
  
 
endclass

`endif
  
