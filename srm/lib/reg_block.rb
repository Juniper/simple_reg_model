require 'json'
require 'pp'

# Register Block is a collection of nodes.
# A node can be another register block and so we can have a tree structure.
# Leaf nodes are either Registers or RegisterArrays.

module SRM
class RegBlock
  attr_accessor :name, :nodes

  def initialize(name:)
    @name = name
    @nodes = []
    yield self if block_given?
  end

  # Add children
  def <<(node)
    @nodes << node
  end

  # Dump all the children
  def to_json(options={})
    {
      "type" => "Block",
      "name" => name,
      "nodes" => @nodes
    }.to_json(options)
  end
end
end
