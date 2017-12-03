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
`ifndef INCLUDED_srm_component_svh
`define INCLUDED_srm_component_svh

typedef class srm_base_handle;
typedef srm_bus_adapter srm_adapters_t[$];
typedef class srm_base_field_policy;

//------------------------------------------------------------
// CLASS: srm_component
// A node in the design tree hierarchy.
//
// A component represents a node in the design hierarchy. Leaf nodes are
// specialized version of this class representing register or register array.
//
// The design hierarchy is an access path for the testwriter to select a component. 
// A design heierarchy can support multiple address map ie the components can have
// different offsets depending on the address map.
//------------------------------------------------------------
class srm_component;
  local string _name;
  protected srm_component _parent;
  local srm_component _children[$];

  protected srm_addr_t _offset_table[string];
  protected srm_addr_t _size_table[string];
  protected srm_adapters_t _adapters;
  protected srm_base_coverage _coverage_cbs[$];

  //---------------------
  // Group: Initialization
  //---------------------

  // Function: new
  //
  // Create a new instance of node with a pointer to parent.
  //
  function new(string name, srm_component parent);
    _name = name;
    _parent = parent;
  endfunction

  //----------------------
  // Group: Introspection
  //----------------------
 
  // Function: get_parent
  // 
  // Return the parent of the node.
  //
  function srm_component get_parent();
    return _parent;
  endfunction

  // Function: get_name
  // 
  // Return the name of the node.
  //
  function string get_name();
    return _name;
  endfunction

  // Function: get_full_name
  // 
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
  //
  // Return true if the node is a leaf node.
  //
  function bit is_leaf_node();
    return (_children.size() == 0);
  endfunction

  // Function: is_root_node
  // 
  // Return true if the node is a root node.
  //
  function bit is_root_node();
    return (_parent == null);
  endfunction

  // Function: add_child
  //
  // Add a child below itself.
  // 
  function void add_child(srm_component child);
    _children.push_back(child);
  endfunction

  // Function: number of children
  // 
  // Return the number of children of the node.
  //
  function int num_children();
    return _children.size();
  endfunction

  // Function: get_children
  //
  // Return array of children of the node.
  //
  function void get_children(ref srm_component children[$]);
    foreach(_children[i])
      children.push_back(_children[i]);

  endfunction

  // Function: get_root_node
  // 
  // Return the root node of the tree.
  //
  function srm_component get_root_node();
    srm_component ptr = this;
    while(!ptr.is_root_node()) ptr = ptr._parent;
    return ptr;
  endfunction

  // Function: get_leaf_nodes
  //
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
  //
  // Set the offset of the node in the address map.
  //
  // ~addr_map_name~ specifies the address map name.
  // 
  // ~offset~ specifies the offset in the address map.
  // A single node may belong to multiple address maps at different offsets.
  //
  virtual function void set_offset(string addr_map_name, srm_addr_t offset);
    _offset_table[addr_map_name] = offset;
  endfunction

  // Function: get_offset
  //
  // Return the offset of node in address map by adding all the offset in path.
  //
  // ~addr_map_name~ specifies the address map to use.
  // Walks up the tree from the current node to the root, adding all the offset.
  // If address map name does not exists, then it is a fatal error.
  //
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

  // Function: set_size
  //
  // Set the size of the node in bytes for the address map.
  //
  // ~addr_map_name~ is the address map name.
  //
  // ~size~ is the software address map size of the node.
  //
  // The size allocated by sofware can be larger than the actual physical size 
  // of the node.
  //
  virtual function void set_size(string addr_map_name, srm_addr_t size);
    _size_table[addr_map_name] = size;
  endfunction

  // Function: get_size
  // Return the number of bytes occupied by the node in the address space.
  //
  // Overriden by register to return the size of the entry. For register array
  // it returns the (size of the entry * number of entries). For non leaf nodes,
  // it returns the sum of the sizes of its children.
  //
  // ~addr_map_name~ is the address map name.
  //
  // The function recursively searches for the child that is the last in the address
  // space. The last address occupied will give the total address space occupied by the
  // node.
  //
  virtual function srm_addr_t get_size(string addr_map_name);
    srm_addr_t size = 0;
    srm_addr_t node_addr_region;
    if(!_size_table.exists(addr_map_name)) begin
      foreach(_children[i]) begin
        node_addr_region = _children[i]._offset_table[addr_map_name] 
                             + _children[i].get_size(addr_map_name);
        if(size < node_addr_region)
          size = node_addr_region;
      end
      _size_table[addr_map_name] = size;
    end
    return _size_table[addr_map_name];
  endfunction

  // Function: address_2_instance
  //
  // Get the instance of the node given the address.
  // ~addr_map_name~ is the address map to be used.
  // ~addr~ is the address to be converted.
  virtual function srm_component address_2_instance(string addr_map_name, srm_addr_t addr);
    srm_component root = get_root_node();
    return root.__address_2_instance(addr_map_name, addr);
  endfunction

  virtual function srm_component __address_2_instance(string addr_map_name, srm_addr_t addr);
    srm_addr_t start_addr, end_addr;
    
    foreach(_children[i]) begin
      start_addr = _children[i].get_offset(addr_map_name);
      end_addr = start_addr + _children[i].get_size(addr_map_name);
      if((addr >= start_addr) && (addr < end_addr)) begin
        if(_children[i].is_leaf_node())
          return _children[i];
        else
          return _children[i].__address_2_instance(addr_map_name, addr);  
      end
    end
    return null;
  endfunction

  //----------------------
  // Group: Adapter Management 
  //----------------------
  // Function: add_adapter
  //
  // Add the adapter to the list.
  //
  // Each node maintains a list of adapters. Depending on the policy one 
  // of the adapters is selected and the leaf node is accessed.
  virtual function void add_adapter(srm_bus_adapter adapter);
    _adapters.push_back(adapter);
  endfunction

  // Function: get_adapters
  //
  // Return the list of adapters at this node.
  //
  virtual function srm_adapters_t get_adapters();
    return _adapters;
  endfunction


  //----------------------
  // Group: Composite Commands 
  //----------------------

  // Task: load
  //
  // Call load on all the leaf nodes of the tree. 
  // 
  //The leaf node will actually call the read and update the model.
  //
  virtual task load(srm_base_handle handle);
    srm_component leaves[$];

    get_leaf_nodes(leaves);

    foreach(leaves[i]) begin
      leaves[i].load(handle);
    end

  endtask

  // Task: store 
  //
  // Call store on all the leaf nodes of the tree.
  // 
  //The leaf node will actually call write and update the design.
  //
  virtual task store(srm_base_handle handle);
    srm_component leaves[$];

    get_leaf_nodes(leaves);

    foreach(leaves[i]) begin
      leaves[i].store(handle);
    end

  endtask


  // Task: store_update 
  //
  // Call store_update on all the children of the node.
  //
  virtual task store_update(srm_base_handle handle, const ref srm_component node, 
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
  

  // Function: set_policy
  //
  // Sets the policy on all the child nodes. 
  //
  virtual function void set_policy(string addr_map_name, srm_base_field_policy policy);
    foreach(_children[i]) begin
      _children[i].set_policy(addr_map_name, policy);
    end
  endfunction

  // Function: reset
  //
  // Reset all the leaf nodes.
  //
  // Leaf nodes implement the base case.
  virtual function void reset(string kind);
    foreach(_children[i]) begin
      _children[i].reset(kind);
    end
  endfunction

  //------------------
  // Group: Model Update
  //-------------------

  // Function: predictor_update
  //
  // Update the component due to the bus transaction.
  //
  // For passive operation the predictor component converts the bus transaction to
  // generic transaction. This function updates the model with this transaction.
  virtual function void predictor_update(const ref srm_generic_xact_t xact);
    if(xact.kind == SRM_WRITE) begin
    end
    else begin
    end
  endfunction

  //----------------------
  // Group: Observer Interface 
  //----------------------

  // Function: attach
  //
  // Attach an observer to all the leaf nodes.
  //
  // No reason for non leaf nodes to detect a read/write.
  virtual function void attach(srm_base_coverage observer);
    srm_component leaves[$];

    get_leaf_nodes(leaves);

    foreach(leaves[i]) begin
      leaves[i].attach(observer);
    end

  endfunction

  // Function: detach
  //
  // Detach all the instances of the observer from leaves.
  //
  virtual function void detach(srm_base_coverage observer);
    srm_component leaves[$];

    get_leaf_nodes(leaves);

    foreach(leaves[i]) begin
      leaves[i].detach(observer);
    end

  endfunction
  
  // Function: detach_all
  //
  // Detach all the the coverage callbacks 
  //
  virtual function void detach_all();
    srm_component leaves[$];

    get_leaf_nodes(leaves);

    foreach(leaves[i]) begin
      leaves[i].detach_all();
    end

  endfunction
  // Function: get_num_coverage_cbs
  //
  // Returns the number of coverage callbacks on the node.
  //
  virtual function int get_num_coverage_cbs();
    return _coverage_cbs.size();
  endfunction

endclass

`endif
  
