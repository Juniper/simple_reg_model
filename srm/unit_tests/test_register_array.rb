require 'minitest/autorun'
require_relative "../lib/srm/register_array"
require 'pp'

class TestRegisterArray < MiniTest::Test
  include SRM
  def test_name
    ra = RegisterArray.new(name: "r1")
    assert_equal "r1", ra.name
  end

  def test_field
    ra = RegisterArray.new(name: "r1", num_entries: 12) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    assert_equal "r1", ra.name
    assert_equal 1, ra.fields.size
    assert_equal "f1", ra.fields[0].name
    assert_equal 12, ra.num_entries
  end

  def test_equal
    r1 = RegisterArray.new(name: "r1", num_entries: 12) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    r1_dup = r1.dup("r1")
    assert_equal true, r1 == r1_dup
  end

  def test_unequal_num_entries
    r1 = RegisterArray.new(name: "r1", num_entries: 12) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    r2 = RegisterArray.new(name: "r1", num_entries: 1) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    assert_equal false, r1 == r2
  end

  def test_unequal_name
    r1 = RegisterArray.new(name: "r1", num_entries: 12) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    r2 = RegisterArray.new(name: "r2", num_entries: 12) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    assert_equal false, r1 == r2
  end

  def test_dup
    r1 = RegisterArray.new(name: "r1_name", num_entries: 12) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    r2 = r1.dup("r2_name")
    assert_equal "r1_name", r1.name
    assert_equal "r2_name", r2.name
  end

  def test_hash
    h = {}
    r1 = RegisterArray.new(name: "r", num_entries: 12) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    h[r1] = 0x100
    assert_equal 0x100, h[r1]

    # Same key but different instance
    r1_dup = RegisterArray.new(name: "r", num_entries: 12) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    h[r1_dup] = 0x200
    assert_equal 0x200, h[r1_dup]
    assert_equal 0x200, h[r1]

  end

  def test_eql
    r1 = RegisterArray.new(name: "r", num_entries: 2) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end

    r1_diff = RegisterArray.new(name: "r", num_entries: 2) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0x0)
    end
    assert_equal(false, r1.eql?(r1_diff))
  end
  
 
  def test_json
    r1 = RegisterArray.new(name: "r", num_entries: 34) do |r|
      r.fields << Field.new(name: 'f1', nbits: 1, lsb_pos: 0,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    end
    json_string = r1.to_json
    h = JSON.parse(json_string, object_class: OpenStruct)
    assert_equal "RegisterArray", h.type
    assert_equal "r", h.name
    assert_equal 34, h.num_entries
    assert_equal "f1", h.fields[0].name
    assert_equal 0xaaabbaacc, h.fields[0].reset_values.mbist
    assert_equal 0x0, h.fields[0].reset_values.hard_reset
  end
end
