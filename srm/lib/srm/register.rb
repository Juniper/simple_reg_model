require_relative "register_array"

module SRM
# A register is an array of fields. It is modelled as a register array of 1 entry. 
class Register < RegisterArray
  def initialize(name:, fields: [])
    super(name: name, fields: fields, num_entries: 1)
    @type = "Register"
  end

end
end
