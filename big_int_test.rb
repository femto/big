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
  def test_exactDivideBy3
    big1 = BigInt.make([21],1)
    assert_equal "7", big1.exactDivideBy3.to_s
  end
  def test_get_lower
    big1 = BigInt.make([1,2,3,4],1)
    assert_equal BigInt.make([3,4],1), big1.getLower(2)
  end
  def test_get_upper
    big1 = BigInt.make([1,2,3,4],1)
    assert_equal BigInt.make([1,2],1), big1.getUpper(2)
  end

  def test_shiftRightImpl
    # big1 = BigInt.make([0x1234,0b10,0b11,0b1001],1)
    # assert_equal BigInt.make([0x48d,0,0x80000000,0xc0000002],1), big1.shiftRightImpl(2)

    big1 = BigInt.make([0x2,0b10,0b11,0b1001],1)
    assert_equal BigInt.make([0x80000000,0x80000000,0xc0000002],1), big1.shiftRightImpl(2)
  end
  def test_shiftRight
    # big1 = BigInt.make([0x1234,0b10,0b11,0b1001],1)
    # assert_equal BigInt.make([0x48d,0,0x80000000,0xc0000002],1), big1.shiftRightImpl(2)

    # big1 = BigInt.make([0x1],-1)
    # assert_equal BigInt.make([0x1],-1), big1.shiftRightImpl(1)
    big1 = BigInt.value_of(-0x2ffffffff)
    assert_equal "-6442450944", big1.shiftRight(1).to_s
    big1 = BigInt.value_of(-0x3ffffffff)
    assert_equal BigInt.make([2,0],-1), big1.shiftRight(1)
    assert_equal "-8589934592", big1.shiftRight(1).to_s
  end
  def test_shift_left
    big1 = BigInt.make([0x80000000],1)
    assert_equal BigInt.make([1,0],1), big1.shiftLeft(1)

    big1 = BigInt.make([0x80000000,0xffffffff],1)
    assert_equal BigInt.make([1,1,0xfffffffe],1), big1.shiftLeft(1)
    big1 = BigInt.make([0x1,0xffffffff],1)
    assert_equal BigInt.make([0b11,0xfffffffe],1), big1.shiftLeft(1)
  end


  def teardown
  end
end