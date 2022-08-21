require_relative 'integer'
class BigInt
  attr_accessor :mag, :signum

  def initialize(str = "", base = 10)
    # Strip leading '+' char to smooth out cases with strings like "+123"
    self.mag = []
    str = str[1..-1] if str[0] == '+'
    # Strip '_' to make it compatible with int literals like "1_000_000"
    str = str.delete('_')

  end
  def ==(other)
    return false unless other.is_a? BigInt
    self.signum == other.signum && self.mag == other.mag
  end



  class << self
    #make a value out of long
    def value_of(val)
      if val == 0
        return ZERO
      end

      if (val < 0)
        val = -val;
        signum = -1;
      else
        signum = 1;
      end

      highWord = val >> 32;
      mag = []
      if (highWord == 0)
        mag << val
      else

        mag << highWord;
        mag << (val & LONG_MASK);
      end
      result = BigInt.new
      result.mag = mag;
      result.signum = signum;
      result
    end

    def make(mag,signum)
      result = BigInt.new
      result.mag = mag;
      result.signum = signum;
      result
    end

    #add two int[] together
    def add_mag(x, y)
      if x.length < y.length
         x,y = y,x
      end
      xIndex = x.length
      yIndex = y.length
      result = Array.new(x.length)
      sum = 0

      if (yIndex == 1)
        sum = (x[xIndex-=1] & LONG_MASK) + (y[0] & LONG_MASK) ;
      result[xIndex] = sum;
       else
         # Add common parts of both numbers
          while (yIndex > 0)
            sum = (x[xIndex-=1] & LONG_MASK) +
              (y[yIndex-=1] & LONG_MASK) + (sum >> 32);
          result[xIndex] = sum;
        end
      end

      carry = (sum >> 32 != 0);
      while (xIndex > 0 && carry)
        carry = (((result[xIndex-=1] = x[xIndex] + 1)) & LONG_MASK == 0)
      end
      while (xIndex > 0)
        result[xIndex-=1] = x[xIndex];
      end
      if carry
        result.unshift(carry)
      end
      result
    end

    #big must > little
    def subtract_mag(big,little)
      bigIndex = big.length;
      result = Array.new(big.length)
      littleIndex = little.length;
      difference = 0;
      borrow = 0;

      #Subtract common parts of both numbers
      while (littleIndex > 0)
          difference = (big[bigIndex-=1] & LONG_MASK) -
            (little[littleIndex-=1] & LONG_MASK) +
            (difference >> 32);
          borrow = -1 if difference < 0;
          difference = difference & LONG_MASK;

        result[bigIndex] = difference;
      end
      while (bigIndex > 0 && borrow)
        borrow = (((result[bigIndex-=1] = big[bigIndex] - 1) & LONG_MASK )== 0xffffffff) #-1;
      end
      while (bigIndex > 0)
        result[bigIndex-=1] = big[bigIndex];
      end
      return result;
    end

    def trustedStripLeadingZeroInts(mag)
      vlen = mag.length;
      index = 0;
      vlen.times do |i|
        index = i
        break if mag[i] != 0
      end
      return [] if mag[index] == 0

      if index == 0
        return mag
      else
        return mag[index..-1]
      end
    end

    #possbily add one last parameter to point to an output array?
    def multiplyToLen(x, xlen, y, ylen)
      xstart = xlen - 1;
      ystart = ylen - 1;
      z = Array.new(xlen + ylen)
      carry = 0;
      j=ystart
      k=ystart+1+xstart
      while j >= 0;
          j-=1
          k-=1
          product = (y[j] & LONG_MASK) *
          (x[xstart] & LONG_MASK) + carry;
        z[k] = product;
        carry = product >> 32;
      end
      z[xstart] = carry;

      i = xstart-1
      while i >= 0
        i -= 1

        carry = 0;
        j=ystart
        k=ystart+1+i
        while j >= 0;
          j-=1
          k-=1
        product = (y[j] & LONG_MASK) *
        (x[i] & LONG_MASK) +
        (z[k] & LONG_MASK) + carry;
      z[k] = product
      carry = product >> 32;
          end
      z[i] = carry;
      end
      return z;

    end
  end


  def hash
    hashCode = 0;

    mag.each do |value|
      hashCode = (31*hashCode + (value & LONG_MASK)) & LONG_MASK
    end

    return hashCode * signum;
  end
  def to_s(radix=10)
    return "0" if (signum == 0)
    radix = 10 if (radix < 2 || radix > 36)
    return smallToString(radix) if (mag.length <= SCHOENHAGE_BASE_CONVERSION_THRESHOLD)
  end

  #using our naive implementation first to override above to_s
  def to_s(radix = 10)
    return "0" if (signum == 0)

    result = mag.each_with_index.reduce(0) do |result,(item,i)|
      result += (item << (32 * (mag.length - i - 1)))
    end
    result = - result if signum == -1
    result.to_s(radix)
  end

  def negate()
    return BigInt.make(this.mag, -this.signum)
  end

  def abs
    return (signum >= 0 ? this : this.negate());
  end

  ZERO = BigInt.make([],0)
  NEGATIVE_ONE = BigInt.make([1],-1)
  LONG_MASK = 0xffffffff;

  SCHOENHAGE_BASE_CONVERSION_THRESHOLD = 20
  MULTIPLY_SQUARE_THRESHOLD = 20
  KARATSUBA_THRESHOLD = 80
  TOOM_COOK_THRESHOLD = 240;

  def +(val)
    return self if (val.signum == 0)
    return val if signum == 0
    return BigInt.make(BigInt.add_mag(mag, val.mag), signum) if (val.signum == signum);
    int cmp = compareMagnitude(val);
    return ZERO if (cmp == 0)
    resultMag = (cmp > 0 ? BigInt.subtract_mag(mag, val.mag)
                   : BigInt.subtract_mag(val.mag, mag));
    resultMag = BigInt.trustedStripLeadingZeroInts(resultMag);
    return BigInt.make(resultMag, cmp == signum ? 1 : -1);

  end
  alias :add :+

  def -(val)
    return self if (val.signum == 0)
    return val.negate if (signum == 0)
    return BigInt.make(BigInt.add_mag(mag, val.mag), signum) if (val.signum != signum)
    cmp = compareMagnitude(val)
    return ZERO if (cmp == 0)
    resultMag = (cmp > 0 ? BigInt.subtract_mag(mag, val.mag)
                   : BigInt.subtract_mag(val.mag, mag));
    resultMag = BigInt.trustedStripLeadingZeroInts(resultMag);
    return BigInt.make(resultMag, cmp == signum ? 1 : -1);
  end
  alias :subtract :-

  def *(val, recursive=false)
    return multiply_internal(val, recursive)
  end
  def multiplyByInt(x,y,sign)
    xlen = x.length
    rmag = Array.new(xlen + 1)
    carry = 0
    yl = y & LONG_MASK
    rstart = rmag.length - 1;
    (xlen - 1).downto(0) do |i|
      product = (x[i] & LONG_MASK) * yl + carry;
      rmag[rstart] = product & LONG_MASK
      rstart -= 1
      carry = product >>  32
    end
    if carry == 0
      rmag = rmag[1..-1]
    else
      rmag[rstart] = carry
    end
    BigInt.make(rmag,sign)
  end
  def multiply_internal(val, recursive=false)
    return ZERO if (val.signum == 0 || signum == 0)
    xlen = mag.length;
    #todo:saure
    # if (val.equal?(self) && xlen > MULTIPLY_SQUARE_THRESHOLD)
    #   return square();
    # end
    ylen = val.mag.length;

    if ((xlen < KARATSUBA_THRESHOLD) || (ylen < KARATSUBA_THRESHOLD))
        resultSign = signum == val.signum ? 1 : -1;
      if (val.mag.length == 1)
        return multiplyByInt(mag,val.mag[0], resultSign);
      end
      if (mag.length == 1)
        return multiplyByInt(val.mag,mag[0], resultSign);
      end

      result = BigInt.multiplyToLen(mag, xlen,
                                   val.mag, ylen);
      result = BigInt.trustedStripLeadingZeroInts(result);
      return BigInt.make(result, resultSign)
    else
      if ((xlen < TOOM_COOK_THRESHOLD) && (ylen < TOOM_COOK_THRESHOLD))
        return multiplyKaratsuba(val)
      else
      end
    end
  end
  alias :multiply :-

  def getLower(n)
    len = mag.length;
    if (len <= n)
      return abs
    end
    result = []
    n.times do |i|
      result << mag[(len - n + i)]
    end
    BigInt.make(result,1)
  end
  def getUpper(n)
    len = mag.length;
    if (len <= n)
      return ZERO;
    end
    upperLen = len - n;
    result = []
    upperLen.times do |i|
      result << mag[i]
    end
    BigInt.make(result,1)
  end
  #todo
  def self.shiftLeft(mag,n)
    nInts = n >> 5;
    nBits = n & 0x1f;
    magLen = mag.length;
    newMag = []
    if (nBits == 0)
      newMag = Array.new(magLen + nInts).fill(0)
      mag.each_with_index do |item, i|
        newMag[i] = item
      end
    else
      i = 0
      nBits2 = 32 - nBits;
      highBits = mag[0] >> nBits2;
      if (highBits != 0)
        newMag = Array.new(magLen + nInts + 1).fill(0);
        newMag[i] = highBits;
        i+=1
       else
        newMag = Array.new(magLen + nInts).fill(0);
      end
      numIter = magLen - 1;
      shiftLeftImplWorker(newMag, mag, i, nBits, numIter)
      newMag[numIter + i] = (mag[numIter] << nBits) & LONG_MASK
    end
    newMag
  end
  def BigInt.shiftLeftImplWorker(newArr,  oldArr,  newIdx,  shiftCount,  numIter)
    shiftCountRight = 32 - shiftCount;
    oldIdx = 0;
    while (oldIdx < numIter)
      newArr[newIdx] = ((oldArr[oldIdx] << shiftCount) & LONG_MASK) | (oldArr[oldIdx +1] >> shiftCountRight);
      newIdx+=1
      oldIdx+=1
    end
  end
  def shiftLeft(n)
    return ZERO if (signum == 0)
    if (n > 0)
      return BigInt.make(BigInt.shiftLeft(mag, n), signum)
    elsif (n == 0)
      return self;
     else
       #// Possible int overflow in (-n) is not a trouble,
       #// because shiftRightImpl considers its argument unsigned
       return shiftRightImpl(-n);
     end
  end
  def shiftRightImpl(n)
    nInts = n >> 5;
    nBits = n & 0x1f;
    magLen = mag.length;
    newMag = []
    if (nInts >= magLen)
      return (signum >= 0 ? ZERO : NEGATIVE_ONE);
    end
    if (nBits == 0)
      newMagLen = magLen - nInts;
      newMagLen.times do |i|
        newMag << mag[i]
      end
    else
      i = 0
      highBits = mag[0] >> nBits;
      if (highBits != 0)
        newMag = Array.new(magLen - nInts);
         newMag[0] = highBits;
         i+=1
      else
        newMag = Array.new(magLen - nInts - 1)
      end
      numIter = magLen - nInts - 1
      shiftRightImplWorker(newMag, mag, i, nBits, numIter);
    end
    if (signum < 0)
      onesLost = false;
      i=magLen-1
      j=magLen-nInts
      while i >= j && !onesLost do
        i-=1
        onesLost = (mag[i] != 0);
      end
      if (!onesLost && nBits != 0)
        onesLost = (mag[magLen - nInts - 1] << (32 - nBits) != 0);
      end
      if (onesLost)
        newMag = javaIncrement(newMag);
      end
    end
    BigInt.make(newMag, signum)
  end
  def shiftRight(n)
    return ZERO if (signum == 0)
    if (n > 0)
      return shiftRightImpl(n);
     elsif (n == 0)
      return self;
     else

       return BigInt.make(BigInt.shiftLeft(mag, -n), signum);
    end
  end
  def javaIncrement(val)
    lastSum = 0;
    i=val.length-1
    while i >= 0 && lastSum == 0

      val[i] = (val[i] + 1) & LONG_MASK;
      lastSum = val[i];
      i-=1
    end
    if (lastSum == 0)
      val = Array.new(val.length + 1).fill(0)
      val[0] = 1;
    end
    val
  end
  def shiftRightImplWorker(newArr, oldArr, newIdx, shiftCount, numIter)
    shiftCountLeft = 32 - shiftCount
    idx = numIter;
    nidx = (newIdx == 0) ? numIter - 1 : numIter;
    while (nidx >= newIdx)
      newArr[nidx] = (oldArr[idx] >> shiftCount) | ((oldArr[idx-1] << shiftCountLeft) & LONG_MASK);
      nidx-=1
      idx-=1
    end
  end
  def multiplyKaratsuba(y)
    x=self
    xlen = x.mag.length
    ylen = y.mag.length
    half = ([xlen, ylen].max+1) / 2;
    xl = x.getLower(half);
    xh = x.getUpper(half);
    yl = y.getLower(half);
    yh = y.getUpper(half);

    p1 = xh.multiply(yh);
    p2 = xl.multiply(yl);
    p3 = xh.add(xl).multiply(yh.add(yl));
    result = p1.shiftLeft(32*half).add(p3.subtract(p1).subtract(p2)).shiftLeft(32*half).add(p2);

    if (x.signum != y.signum)
      return result.negate();
    else
      return result;
    end
  end

  def compareMagnitude(val)
    len1 = self.mag.length
    len2 = val.mag.length
    return -1 if (len1 < len2)
    return 1 if (len1 > len2)
    #now same length
    self.mag.each_with_index do |a,i|
      b=val.mag[i]
      return ((a & LONG_MASK) < (b & LONG_MASK)) ? -1 : 1 if a != val.mag[i]
    end
    return 0
  end

  def exactDivideBy3
    len = mag.length;
    result = Array.new(len)
    borrow = 0
    (len-1).downto(0) do |i|
      x = (mag[i] & LONG_MASK);
      w = x - borrow;
      if (borrow > x)
        borrow = 1;
      else
        borrow = 0
      end
      q = (w * 0xAAAAAAAB) & LONG_MASK;
      result[i] = q
      if (q >= 0x55555556)
        borrow+=1
        if (q >= 0xAAAAAAAB)
          borrow+=1;
        end
      end
      result = BigInt.trustedStripLeadingZeroInts(result);
      return BigInt.make(result, signum)
    end
  end

  private
    def smallToString(radix)
      return "0" if (signum == 0)
      tmp = this.abs()
      numGroups = 0;
      while (tmp.signum != 0)
        d = longRadix[radix];
      end
    end
end

BigInteger = BigInt

class Integer
  def power(exponent)
    #assume num is integer
    if exponent < 0
      raise ArgumentError.new "Cannot raise an integer to a negative integer power, use floats for that"
    end

    result = 1
    k = self
    while exponent > 0
      result *= k if exponent & 0b1 != 0
      exponent >>= 1
      k *= k if exponent > 0
    end
    result
  end
end