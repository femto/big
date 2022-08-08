class Integer
  LONG_MASK = 0xffffffff;
  class << self

    #return 32 bit integer's bit count
    def bitCount(i)
      # HD, Figure 5-2
        i = i& LONG_MASK #convert to unsigned integer
      i = i - ((i >> 1) & 0x55555555);
      i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
      i = (i + (i >> 4)) & 0x0f0f0f0f;
      i = i + (i >> 8);
      i = i + (i >> 16);
      return i & 0x3f;
    end
    def numberOfLeadingZeros(i)
      #HD, Figure 5-6
      return 32 if (i == 0)

      n = 1;
      i = i& LONG_MASK #convert to unsigned integer
      if (i >> 16 == 0) then  n += 16; i <<= 16 end
      if (i >> 24 == 0) then n +=  8; i <<=  8; end
      if (i >> 28 == 0) then n +=  4; i <<=  4; end
      if (i >> 30 == 0) then n +=  2; i <<=  2; end
      n -= i >> 31;
      return n;
    end

    def numberOfTrailingZeros(i) 
      # HD, Figure 5-14
      return 32 if(i == 0)
      i = i& LONG_MASK #convert to unsigned integer

      int n = 31;
      y = (i <<16 ) & LONG_MASK; if (y != 0) then n = n -16; i = y; end
      y = (i << 8) & LONG_MASK; if (y != 0) then n = n - 8; i = y; end
      y = (i << 4) & LONG_MASK; if (y != 0) then n = n - 4; i = y; end
      y = (i << 2) & LONG_MASK; if (y != 0) then n = n - 2; i = y; end
      return n - (((i << 1) & LONG_MASK ) >> 31);
    end

  end
end