require 'minitest/autorun'
require 'ostruct'
require_relative "../lib/srm/field"

class TestField < MiniTest::Test

  def setup
    @f1 = SRM::Field.new(name: 'f1', nbits: 1, lsb_pos: 0xaaabbb,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    @f1.set_policy("cpu_map" =>"srm_rw_policy")
  end

  def test_name
    assert_equal "f1", @f1.name
    assert_equal  1, @f1.nbits 
    assert_equal 0xaaabbb, @f1.lsb_pos
    assert_equal 0x0, @f1.reset_types[:hard_reset]
    assert_equal 0xaaabbaacc, @f1.reset_types[:mbist]
  end

  def test_hash
    f1_dup = SRM::Field.new(name: 'f1', nbits: 1, lsb_pos: 0xaaabbb,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    f2  = SRM::Field.new(name: 'f2', nbits: 1, lsb_pos: 0xaaabbb,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    assert_equal @f1.hash, f1_dup.hash
    assert_equal true, @f1.hash != f2.hash
  end

  def test_eql
    f1_dup = SRM::Field.new(name: 'f1', nbits: 1, lsb_pos: 0xaaabbb,  hard_reset: 0x0, mbist: 0xaaabbaacc)
    f1_diff = SRM::Field.new(name: 'f1', nbits: 1, lsb_pos: 0xaaabbb,  hard_reset: 0x0, mbist: 0x0)
    assert_equal true, @f1.eql?(f1_dup)
    assert_equal true, !@f1.eql?(f1_diff)
  end
 
  def test_policy
    assert_equal "srm_rw_policy", @f1.policy("cpu_map")
  end

  def test_multi_policy
    f2 = @f1
    f2.set_policy("gpu_map" =>"srm_read_policy")
    assert_equal "srm_rw_policy", f2.policy("cpu_map")
    assert_equal "srm_read_policy", f2.policy("gpu_map")
  end

  def test_json
    json_string = @f1.to_json
    h = JSON.parse(json_string, object_class: OpenStruct)
    assert_equal "Field", h.type
    assert_equal "f1", h.name
    assert_equal 1, h.nbits
    assert_equal 0xaaabbb, h.lsb_pos
    assert_equal 0x0, h.reset_types["hard_reset"]
    assert_equal 0xaaabbaacc, h.reset_types["mbist"]
    assert_equal "srm_rw_policy", h.policies["cpu_map"]
  end

end

