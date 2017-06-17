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
  protected srm_component _parent;
  local srm_component _children[$];
  protected srm_addr_t _offset_table[string];
  protected srm_adapters_t _adapters;

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
  // 
  // It also creates an entry in the offset table to record the offset.
  function void add_child(srm_component child);
    _children.push_back(child);
  endfunction

  // Function: number of children
  // Return the number of children
  function int num_children();
    return _children.size();
  endfunction

  function void get_children(ref srm_component children[$]);
    foreach(_children[i])
      children.push_back(_children[i]);

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
  // Group: Address Computation
  //----------------------
 
  // Function: set_offset
  // Set the offset of the node in the address map.
  virtual function void set_offset(string addr_map_name, srm_addr_t offset);
    _offset_table[addr_map_name] = offset;
  endfunction

  // Function: get_offset
  // Return the offset of node in address map by adding all the offset in path.
  //
  // If address map name does not exists, then it is a fatal error.
  virtual function srm_addr_t get_offset(string addr_map_name);
    srm_addr_t offset;
    srm_component p;
    if(!_offset_table.exists(addr_map_name)) begin
      // By default return 0 for root node even when the user has not specified it.
      if(is_root_node()) 
        return 0;
      else 
        `uvm_fatal("TbConfigurationError", 
          $psprintf("Unknown address map name \"%s\" for get_offset", addr_map_name));
    end
    offset = _offset_table[addr_map_name];
    p = get_parent();
    while(p != null) begin
      offset += p._offset_table[addr_map_name];
      p = p.get_parent();
    end
    return offset;
  endfunction

  //----------------------
  // Group: Adapter Management 
  //----------------------
  // Function: add_adapter
  // Add the adapter to the list.
  //
  // Each node maintains a list of adapters.
  virtual function void add_adapter(srm_bus_adapter adapter);
    _adapters.push_back(adapter);
  endfunction

  // Function: get_adapters
  // Return the list of adapters at this node.
  //
  virtual function srm_adapters_t get_adapters();
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
  // Leaf class will override this for the base case.
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
  

  // Function: reset
  // Reset all the leaf nodes.
  // Leaf nodes implement the base case.
  virtual function void reset(string kind);
    foreach(_children[i])
      _children[i].reset(kind);
  endfunction


endclass

`endif
  
