require 'json'

# A field is a has of attributes describing a contiguous set of bits. 
# It has reset values for each type of reset (string) and different access
# policy (like read_write, read_only, write_only) depending on the address map (string)

module SRM
class Field
  attr_reader :name, :nbits, :lsb_pos, :volatile, :reset_types

  def initialize(name:, nbits:, lsb_pos:, volatile:false, **reset_types)
    @name = name
    @nbits = nbits
    @lsb_pos = lsb_pos
    @volatile = volatile
    @reset_types = reset_types
    @policies = {}
  end

  def hash
    name.hash ^ nbits.hash ^ lsb_pos.hash ^ volatile.hash
  end

  def to_s
    "printing instance"
  end

  def to_s1
    "Field: name:#{name}, nbits:${n_bits}, lsb_pos:#{lsb_pos}, volatile: #{volatile}, reset_types: #{reset_types}"
  end

  def eql?(other)
    self.==(other)
  end
  
  def ==(other)
    name == other.name && nbits == other.nbits &&
    lsb_pos == other.lsb_pos && reset_types == other.reset_types
  end

  def set_policy(args)
    args.each {|k, v| @policies[k] = v }
    self
  end

  def policy(address_map_name)
    @policies[address_map_name]
  end

  def to_json(options={})
    {
      "type" => "Field",
      "name" => @name, 
      "nbits" => @nbits, 
      "lsb_pos" => @lsb_pos,
      "volatile" => @volatile, 
      "reset_types" => @reset_types,
      "policies" => @policies
    }.to_json(options)
  end

end
end
