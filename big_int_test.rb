require 'minitest/autorun'
require './big_int'
# 注意有些资料中，测试类不是继承自MiniTest::Test，
# 那是MiniTest 5之前的做法，MiniTest会通知你改正
class TestBigInt < MiniTest::Test
  # 这个方法会在各个测试之前被调用
  def setup
    #@big = Big.new("0.00")
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

    big1 = BigInt.make([1,4],1)
    big2 = BigInt.value_of(5)

    big3 = big1 + big2

    assert_equal BigInt.make([1,9],1),big1+big2
    # assert_equal 0, big3.scale
  end
  def test_sub
    # big1 = BigInt.value_of(5)
    # big2 = BigInt.value_of(3)
    # assert_equal BigInt.value_of(2), big1 - big2
    # assert_equal BigInt.value_of(-2), big2 - big1
    #
    # big1 = BigInt.value_of(-5)
    # big2 = BigInt.value_of(3)
    # assert_equal BigInt.value_of(-8), big1 - big2
    # assert_equal BigInt.value_of(8), big2 - big1
    #
    # big1 = BigInt.value_of(-3)
    # big2 = BigInt.value_of(5)
    # assert_equal BigInt.value_of(-8), big1 - big2
    # assert_equal BigInt.value_of(8), big2 - big1
    #
    # big1 = BigInt.value_of(3)
    # big2 = BigInt.value_of(5)
    # assert_equal BigInt.value_of(-2), big1 - big2
    # assert_equal BigInt.value_of(2), big2 - big1
    #
    # big1 = BigInt.make([1,9],1)
    # big2 = BigInt.value_of(5)
    # assert_equal BigInt.make([1,4],1), big1 - big2
    # assert_equal BigInt.make([1,4],-1), big2 - big1

    big1 = BigInt.make([1,4],1)
    big2 = BigInt.value_of(5)
    assert_equal BigInt.value_of(4294967295), big1 - big2
    assert_equal BigInt.value_of(-4294967295), big2 - big1

  end
  def test_eql
    big1 = BigInt.value_of(5)
    big2 = BigInt.value_of(5)
    assert_equal false, big2.eql?(big1) #hash uses eql?
    assert_equal false, big2.equal?(big1) #verify object identity
    assert_equal true, big2 === big1
  end
  def test_trustedStripLeadingZeroInts
    assert_equal BigInt.trustedStripLeadingZeroInts([0,0, 1,4]), [1,4]
    assert_equal BigInt.trustedStripLeadingZeroInts([0, 1,4]), [1,4]
    assert_equal BigInt.trustedStripLeadingZeroInts([0, 0,0]), []
    assert_equal BigInt.trustedStripLeadingZeroInts([0]), []
  end

  def test_multiplyByInt
    big1 = BigInt.make([1,4],1)
    assert_equal BigInt.make([4,16],1), big1 * BigInt.value_of(4)
  end

  def test_bitCount
    assert_equal 32, Integer.bitCount(0xffffffff)
  end

  def test_to_s
    big1 = BigInt.make([1,4],1)
    assert_equal "4294967300", big1.to_s
  end


  def teardown
  end
end