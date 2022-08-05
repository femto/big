require_relative 'big_int'
class InvalidBigDecimalException < Exception
  def initialize(big_decimal_str, reason)
    super("Invalid BigDecimal: #{big_decimal_str} (#{reason})")
  end
end

class DivisionByZeroError < Exception
  def initialize()
    super("Unhandled exception: Division by 0")
  end
end

class Big < Numeric
  ZERO = 0
  TEN = 10
  DEFAULT_MAX_DIV_ITERATIONS = 100
  attr_reader :value, :scale

  def self.new(num, scale = nil)
    if num.is_a?(Float)
      return new(num.to_s)
    end
    if num.is_a?(Integer) && scale.nil?
      return new(num, 0)
    end
    if num.is_a?(self)
      return num
    end
    super

  end

  def initialize(num, scale = nil)
    if scale
      @value = num.to_i #should we call num.to_i ?
      @scale = scale
    end
    if num.is_a?(String)
      str = num
      str = str.delete_prefix('+')
      str = str.delete("_")
      raise InvalidBigDecimalException.new(str, "Zero size") if str.bytesize == 0

      # Check str's validity and find index of '.'
      decimal_index = nil
      # Check str's validity and find index of 'e'
      exponent_index = nil

      str.each_char.with_index do |char, index|
        case char
        when '-'
          unless index == 0 || exponent_index == index - 1
            raise InvalidBigDecimalException.new(str, "Unexpected '-' character")
          end
        when '+'
          unless exponent_index == index - 1
            raise InvalidBigDecimalException.new(str, "Unexpected '+' character")
          end
        when '.'
          if decimal_index
            raise InvalidBigDecimalException.new(str, "Unexpected '.' character")
          end
          decimal_index = index
        when 'e', 'E'
          if exponent_index
            raise InvalidBigDecimalException.new(str, "Unexpected #{char.inspect} character")
          end
          exponent_index = index
        when '0'..'9'
          # Pass
        else
          raise InvalidBigDecimalException.new(str, "Unexpected #{char.inspect} character")
        end
      end

      decimal_end_index = (exponent_index || str.size) - 1
      if decimal_index
        decimal_count = (decimal_end_index - decimal_index)

        io = StringIO.new
        # We know this is ASCII, so we can slice by index
        io << (str[0, decimal_index])
        io << (str[decimal_index + 1, decimal_count])
        @value = io.string.to_i
      else
        decimal_count = 0
        @value = str[0..decimal_end_index].to_i
      end

      if exponent_index
        exponent_postfix = str[exponent_index + 1]
        case exponent_postfix
        when '+', '-'
          exponent_positive = exponent_postfix == '+'
          exponent = str[(exponent_index + 2)..-1].to_i
        else
          exponent_positive = true
          exponent = str[(exponent_index + 1)..-1].to_i
        end

        @scale = exponent
        if exponent_positive
          if @scale < decimal_count
            @scale = decimal_count - @scale
          else
            @scale -= decimal_count
            @value *= 10 ** @scale
            @scale = 0
          end
        else
          @scale += decimal_count
        end
      else
        @scale = decimal_count
      end

    end
  end

  def -
    self.class.new(-@value, @scale)
  end

  def +(other)
    other = self.class.new(other)
    if @scale > other.scale
      scaled = other.scale_to(self)
      Big.new(@value + scaled.value, @scale)
    elsif @scale < other.scale
      scaled = scale_to(other)
      Big.new(scaled.value + other.value, other.scale)
    else
      Big.new(@value + other.value, @scale)
    end
  end

  def -(other)
    other = self.class.new(other)
    if @scale > other.scale
      scaled = other.scale_to(self)
      Big.new(@value - scaled.value, @scale)
    elsif @scale < other.scale
      scaled = scale_to(other)
      Big.new(scaled.value - other.value, other.scale)
    else
      Big.new(@value - other.value, @scale)
    end
  end

  def *(other)
    other = self.class.new(other)
    Big.new(@value * other.value, @scale + other.scale)
  end

  def /(other)
    other = self.class.new(other)
    div other
  end

  def div(other, max_div_iterations = DEFAULT_MAX_DIV_ITERATIONS)
    check_division_by_zero other
    other.factor_powers_of_ten

    scale = @scale - other.scale
    numerator, denominator = @value, other.value

    quotient, remainder = numerator.divmod(denominator)

    if remainder == ZERO
      return Big.new(normalize_quotient(other, quotient), scale)
    end

    remainder = remainder * TEN
    i = 0
    while remainder != ZERO && i < max_div_iterations
      inner_quotient, inner_remainder = remainder.divmod(denominator)
      quotient = quotient * TEN + inner_quotient
      remainder = inner_remainder * TEN
      i += 1
    end

    Big.new(normalize_quotient(other, quotient), scale + i)
  end

  def <=>(other)
    other = self.class.new(other)
    if @scale > other.scale
      @value <=> other.scale_to(self).value
    elsif @scale < other.scale
      scale_to(other).value <=> other.value
    else
      @value <=> other.value
    end
  end

  def ==(other)
    other = self.class.new(other)
    case @scale
    when @scale > (other.scale)
      scaled = other.value * power_ten_to(@scale - other.scale)
      @value == scaled
    when @scale < (other.scale)
      scaled = @value * power_ten_to(other.scale - @scale)
      scaled == other.value
    else
      @value == other.value
    end
  end


  def scale_to(new_scale)
    in_scale(new_scale.scale)
  end

  def in_scale(new_scale)
    if @value == 0
      Big.new(0, new_scale)
    elsif @scale > new_scale
      scale_diff = @scale - new_scale
      Big.new(@value / power_ten_to(scale_diff), new_scale) #should we floor this?
    elsif @scale < new_scale
      scale_diff = new_scale - @scale
      Big.new(@value * power_ten_to(scale_diff), new_scale)
    else
      self
    end
  end

  def **(other)
    if other < 0
      raise ArgumentError.new("Negative exponent isn't supported")
    end
    Big.new(@value ** other, @scale * other)
  end

  def ceil
    mask = power_ten_to(@scale)
    diff = (mask - @value % mask) % mask
    value = self + Big.new(diff, @scale)
    value.in_scale(0)
  end

  def floor
    in_scale(0)
  end

  def trunc
    self < 0 ? ceil : floor
  end

  def to_s(io = "")
    factor_powers_of_ten

    s = @value.to_s
    if @scale == 0
      io << s
      return
    end

    if @scale >= s.size && @value >= 0
      io << "0."
      (@scale - s.size).times do
        io << '0'
      end
      io << s
    elsif @scale >= (s.size-1) && @value < 0
      io << "-0."
      (@scale - s.size).times do
        io << '0'
      end
      io << s[1..-1]
    else
      offset = s.size - @scale
      io << s[0...offset] << '.' << s[offset..-1]
    end
  end


  def normalize_quotient(other, quotient)
    if (@value < 0 && other.value > 0) || (other.value < 0 && @value > 0)
      -quotient.abs
    else
      quotient
    end
  end

  private def check_division_by_zero(bd)
    raise DivisionByZeroError.new if bd.value == 0
  end

  private def power_ten_to(x)
    TEN ** x
  end

  protected def factor_powers_of_ten
    while @scale > 0
      quotient, remainder = value.divmod(TEN)
      break if remainder != 0

      @value = quotient
      @scale = @scale - 1
    end
  end
end