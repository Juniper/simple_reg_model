require 'minitest/autorun'
require_relative "../lib/register"
require 'pp'

class TestRegister < MiniTest::Test
  include SRM
  def setup
    @r1 = Register.new(name: "r1") do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
  end

  def test_name
    register = Register.new(name: "r1")
    assert_equal "r1", register.name
  end

  def test_field
    assert_equal "r1", @r1.name
    assert_equal 1, @r1.fields.size
    assert_equal "f1", @r1.fields[0].name
    assert_equal 1, @r1.width
  end

  def test_equal
    r1_dup = @r1.dup("r1")
    assert_equal true, @r1 == r1_dup
  end

  def test_dup
    r2 = @r1.dup("r2_name")
    assert_equal "r1", @r1.name
    assert_equal "r2_name", r2.name
  end

  def test_hash
    h = {}
    h[@r1] = 0x100
    assert_equal 0x100, h[@r1]

    # Same key but different instance
    r1_dup = Register.new(name: "r1") do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    h[r1_dup] = 0x200
    assert_equal 0x200, h[r1_dup]
    assert_equal 0x200, h[@r1]

  end

  def test_eql
    r1_diff = Register.new(name: "r") do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0x0)
    end
    assert_equal(false, @r1.eql?(r1_diff))
  end
  

  def test_offset
    @r1.offset(cpu_map: 0x100)
    assert_equal(@r1.offsets[:cpu_map], [0x100, 1])
    assert_equal(0x100, @r1.start_offset(:cpu_map))
    assert_equal 1, @r1.size(:cpu_map)
  end

  def test_alt_offset_syntax
    r1 = Register.new(name: "r") do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end.offset(cpu_map: 0x100)
    assert_equal(r1.offsets[:cpu_map], [0x100, 1])
  end

  def test_alt2_offset_syntax
    r1 = Register.new(name: "r1")
    r1.offset("cpu_map" => [0x100, 0x32])
    assert_equal("r1", r1.name)  
  end

  def test_multi_offset
    @r1.offset(cpu_map: 0x100, gpu_map: 0x200)
    assert_equal(@r1.offsets[:cpu_map], [0x100, 1])
    assert_equal([0x200, 1], @r1.offsets[:gpu_map])
  end

  def test_offset_size
    @r1.offset(cpu_map: [0x100, 0x32])
    assert_equal(@r1.offsets[:cpu_map], [0x100, 0x32])
  end

  def test_multi_offset_size
    @r1.offset(cpu_map: [0x100, 0x32], gpu_map: [0x200, 0x16])
    assert_equal([0x100, 0x32], @r1.offsets[:cpu_map])
    assert_equal([0x200, 0x16], @r1.offsets[:gpu_map])
  end

  def test_json
    json_string = @r1.to_json
    h = JSON.parse(json_string, object_class: OpenStruct)
    assert_equal "Register", h.type
    assert_equal "r1", h.name
    assert_equal "f1", h.fields[0].name
    assert_equal 0xaaabbaacc, h.fields[0].reset_types.mbist
    assert_equal 0x0, h.fields[0].reset_types.hard_reset
  end

  def test_json_offsets
    @r1.offset(cpu_map: [0x100, 0x32], gpu_map: [0x200, 0x16])
    json_string = @r1.to_json
    h = JSON.parse(json_string, object_class: OpenStruct)
    assert_equal [0x100, 0x32], h.offsets["cpu_map"]
  end

end
