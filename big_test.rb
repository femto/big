require 'minitest/autorun'
require './big'
# 注意有些资料中，测试类不是继承自MiniTest::Test，
# 那是MiniTest 5之前的做法，MiniTest会通知你改正
class TestMyLife < MiniTest::Test
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
  end

  def test_build_from_string_exponent
    # big1 = Big.new("0.00")
    # assert_equal 0, big1.value
    # assert_equal 0, big1.scale

    big2 = Big.new("3.e1")
    assert_equal 30, big2.value
    assert_equal 0, big2.scale

    # big3 = Big.new("3")
    # assert_equal 3, big3.value
    # assert_equal 0, big3.scale
  end

  def test_add
    # big2 = Big.new("3.e1")
    # assert_equal 30, big2.value
    # assert_equal 0, big2.scale
    #
     big3 = Big.new("3")
     assert_equal 3, big3.value
     assert_equal 0, big3.scale
    #
    # big4 = big2+big3
    # assert_equal 33, big4.value
    # assert_equal 0, big4.scale

    big2 = Big.new(3,1)
    big4 = big2+big3
    assert_equal 33, big4.value
    assert_equal 1, big4.scale
  end

  def test_sub
    # big2 = Big.new("3.e1")
    # assert_equal 30, big2.value
    # assert_equal 0, big2.scale
    #
    big3 = Big.new("3")
    assert_equal 3, big3.value
    assert_equal 0, big3.scale
    #
    # big4 = big2+big3
    # assert_equal 33, big4.value
    # assert_equal 0, big4.scale

    big2 = Big.new(4,1)
    big4 = big3-big2
    assert_equal 26, big4.value
    assert_equal 1, big4.scale
  end

  def test_mul
    # big2 = Big.new("3.e1")
    # assert_equal 30, big2.value
    # assert_equal 0, big2.scale
    #
    big3 = Big.new("0.3")
    assert_equal 3, big3.value
    assert_equal 1, big3.scale
    #
    # big4 = big2+big3
    # assert_equal 33, big4.value
    # assert_equal 0, big4.scale

    big2 = Big.new(4,1)
    big4 = big3*big2
    assert_equal 12, big4.value
    assert_equal 2, big4.scale
  end

  def test_div
    # big2 = Big.new("3.e1")
    # assert_equal 30, big2.value
    # assert_equal 0, big2.scale
    #
    big3 = Big.new("0.3")
    assert_equal 3, big3.value
    assert_equal 1, big3.scale

    big0 = Big.new("0.0")
    assert_equal 0, big0.value
    assert_equal 1, big0.scale

    assert_raises DivisionByZeroError do
      big3/big0
    end

    #
    # big4 = big2+big3
    # assert_equal 33, big4.value
    # assert_equal 0, big4.scale

    big2 = Big.new(4,1)
    big4 = big3/big2
    assert_equal 75, big4.value
    assert_equal 2, big4.scale

    big = Big.new(1).div(Big.new(2))
    assert_equal 5, big.value
    assert_equal 1, big.scale

    big = Big.new(1).div(Big.new(3), 5)

    assert_equal 33333, big.value
    assert_equal 5, big.scale
  end

  def test_compare
    big3 = Big.new("0.3")
    assert_equal 3, big3.value
    assert_equal 1, big3.scale

    big4 = Big.new("4.2")
    assert_equal 42, big4.value
    assert_equal 1, big4.scale

    result = big3 <=> big4

    assert_equal -1, result
  end

  def test_equal
    big3 = Big.new("0.3")
    assert_equal 3, big3.value
    assert_equal 1, big3.scale

    big4 = Big.new("4.2")
    assert_equal 42, big4.value
    assert_equal 1, big4.scale

    result = big3 == big4

    assert !result

    big3 = Big.new("0.3")
    assert_equal 3, big3.value
    assert_equal 1, big3.scale

    big4 = Big.new("3e-1")
    assert_equal 3, big4.value
    assert_equal 1, big4.scale

    result = big3 == big4

    assert result

    assert big3 == 0.3
  end

  def test_power
    big = Big.new(1234, 2) ** 2
    assert_equal 152.2756, big

  end

  def test_ceil
    big = Big.new(123456, 4)
    assert_equal 13, big.ceil

    big = Big.new(-123456, 4)
    assert_equal -12, big.ceil

  end

  def test_to_s
    # big = Big.new(3456, 4)
    # assert_equal "0.3456",big.to_s
    #
    # big = Big.new(-3456, 4)
    # assert_equal "-0.3456",big.to_s

    big = Big.new(123456, 4)
    assert_equal "12.3456",big.to_s

    big = Big.new(-123456, 4)
    assert_equal "-12.3456",big.to_s
  end

  def test_sleep
    # assert_equal exp, act, msg
    #assert_equal   "zzZ", @big.sleep, "I don't sleep well "
  end

  def teardown
  end
end