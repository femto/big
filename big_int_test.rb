require 'minitest/autorun'
require './big_int'
# 注意有些资料中，测试类不是继承自MiniTest::Test，
# 那是MiniTest 5之前的做法，MiniTest会通知你改正
class TestBigInt < MiniTest::Test
  # 这个方法会在各个测试之前被调用
  def setup
    #@big = Big.new("0.00")
  end

  def test_build_from_string
    # big1 = Big.new("0.00")
    # assert_equal 0, big1.value
    # assert_equal 0, big1.scale

    big2 = Big.new("3.")
    assert_equal 3, big2.value
    assert_equal 0, big2.scale

    big3 = Big.new("3")
    assert_equal 3, big3.value
    assert_equal 0, big3.scale

    big4 = Big.new(".1234")
    assert_equal 1234, big4.value
    assert_equal 4, big4.scale
  end

  def test_add
    # big1 = Big.new("0.00")
    # assert_equal 0, big1.value
    # assert_equal 0, big1.scale

    big1 = BigInt.value_of(5)
    big2 = BigInt.value_of(0)

    big3 = big1 + big2
    assert_equal big3, big1

    big1 = BigInt.value_of(4)
    big2 = BigInt.value_of(5)

    big3 = BigInt.value_of(9)

    assert_equal big3, big1 + big2

    # big3 = Big.new("3")
    # assert_equal 3, big3.value
    # assert_equal 0, big3.scale
  end


  def teardown
  end
end