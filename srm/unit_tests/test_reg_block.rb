require 'minitest/autorun'
require 'ostruct'
require_relative "../lib/reg_block"
require_relative "../lib/register"


class TestRegBlock < MiniTest::Test
include SRM

  def setup
    @reg_block = RegBlock.new(name: 'cpu_registers') do |block|
      block << Register.new(name: "r1").offset("cpu_map" => [0x100, 0x32], 
                                           "gpu_map" => [0x200, 0x16])
    end
  end

  def test_name
    assert_equal("cpu_registers", @reg_block.name)
  end

end

