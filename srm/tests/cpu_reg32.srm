# Create a 32 bit register in cpu map at offset 0x100.

RegBlock.new(name: "top") do |block|
  block << Register.new(name: "r1_reg", reset_kinds: [:hard_reset]) do |reg|
    reg << Field.new(name: "field0", nbits: 16, lsb_pos:0, hard_reset: 0xbeef)
    reg << Field.new(name: "field1", nbits: 16, lsb_pos:16, hard_reset: 0xdead)
  end.offset(cpu_map: 0x100)
end


