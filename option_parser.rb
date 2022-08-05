class OptionParser1
  class Exception < ::Exception
  end

  class InvalidOption < Exception
    def initialize(option)
      super("Invalid option: #{option}")
    end
  end

  class MissingOption < Exception
    def initialize(option)
      super("Missing option: #{option}")
    end
  end

  class Handler
    attr :flag, :block #flag is a string, block is a block
    def initialize(flag, block)
      @flag = flag
      @block = block
    end
  end

  def self.parse(args = ARGV)
    parser = OptionParser1.new
    yield parser
    parser.parse(args)
    parser
  end

  def self.new()
    super.tap {|parser| yield parser}
  end

  attr_accessor :banner,:handlers
  def initialize
    @flags = [] #of String
    @handlers = [] #of Handler
    @missing_option = ->(option ) { raise MissingOption.new(option) }
    @invalid_option = ->(option ) { raise InvalidOption.new(option) }
  end

  def on(*args,&block)
    if args.size == 2
      on2(*args, &block)
    elsif args.size == 3
      on3(*args,&block)
    end
  end

  def on2(flag , description , &block)
    check_starts_with_dash flag, "flag"

    append_flag flag, description
    @handlers << Handler.new(flag, block)
  end

  def on3(short_flag , long_flag , description , &block)
    check_starts_with_dash short_flag, "short_flag", allow_empty: true
    check_starts_with_dash long_flag, "long_flag"

    append_flag "#{short_flag}, #{long_flag}", description

    has_argument = /([ =].+)/
    if long_flag =~ has_argument
      argument = $1
      short_flag += argument unless short_flag =~ has_argument
    end

    @handlers << Handler.new(short_flag, block)
    @handlers << Handler.new(long_flag, block)
  end

  def separator(message = "")
    @flags << message.to_s
  end

  def unknown_args(&unknown_args)
    @unknown_args = unknown_args
  end
  #
  # # Sets a handler for when a option that expects an argument wasn't given any.
  # #
  # # You typically use this to display a help message.
  # # The default raises `MissingOption`.
  def missing_option(&missing_option)
    @missing_option = missing_option
  end
  def invalid_option(&invalid_option)
    @invalid_option = invalid_option
  end
  #
  def to_s(io="")
    if banner = @banner
      io << banner
      io << '\n'
    end
    @flags.join '\n', io
  end

  private def append_flag(flag, description)
    if flag.size >= 33
      @flags << "    #{flag}\n#{" " * 37}#{description}"
    else
      @flags << "    #{flag}#{" " * (33 - flag.size)}#{description}"
    end
  end

  private def check_starts_with_dash(arg, name, allow_empty = false)
    return if allow_empty && arg.empty?

    unless arg.start_with?('-')
      raise ArgumentError.new("Argument '#{name}' (#{arg.inspect}) must start with a dash (-)")
    end
  end

  def parse(args = ARGV)
    ParseTask.new(self, args).parse
  end

  class ParseTask
    attr_accessor :parser, :args
    def initialize(parser,args)
      @parser = parser
      @args = args

      double_dash_index = @double_dash_index = @args.index("--")
      if double_dash_index
        @args.delete_at(double_dash_index)
      end
    end

    def parse
      @parser.handlers.each do |handler|
        process_handler handler
      end

      if unknown_args = @parser.unknown_args
        double_dash_index = @double_dash_index
        if double_dash_index
          before_dash = @args[0...double_dash_index]
          after_dash = @args[double_dash_index..-1]
        else
          before_dash = @args
          after_dash = []
        end
        unknown_args.call(before_dash, after_dash)
      end

      check_invalid_options
    end

    private def process_handler(handler)
      flag = handler.flag
      block = handler.block
      case flag
      when /--(\S+)\s+\[\S+\]/
        process_double_flag("--#{$1}", block)
      when /--(\S+)(\s+|\=)(\S+)?/
        process_double_flag("--#{$1}", block, true)
      when /--\S+/
        process_flag_presence(flag, block)
      when /-(.)\s*\[\S+\]/
        process_single_flag(flag[0..1], block)
      when /-(.)\s+\S+/, /-(.)\s+/, /-(.)\S+/
        process_single_flag(flag[0..1], block, true)
      else
        process_flag_presence(flag, block)
      end
    end

    private def process_flag_presence(flag, block)
      while index = args_index(flag)
        delete_arg_at_index(index)
        block.call ""
      end
    end

    private def process_double_flag(flag, block, raise_if_missing = false)
      while index = args_index { |arg| arg.split('=')[0] == flag }
        arg = @args[index]
        if arg.size == flag.size
          delete_arg_at_index(index)
          if index < args_size
            block.call delete_arg_at_index(index)
          else
            if raise_if_missing
              @parser.missing_option.call(flag)
            end
          end
        elsif arg[flag.size] == '='
          delete_arg_at_index(index)
          value = arg[flag.size + 1..-1]
          if value.empty?
            @parser.missing_option.call(flag)
          else
            block.call value
          end
        end
      end
    end

    private def process_single_flag(flag, block, raise_if_missing = false)
      while index = args_index { |arg| arg.starts_with?(flag) }
        arg = delete_arg_at_index(index)
        if arg.size == flag.size
          if index < args_size
            block.call delete_arg_at_index(index)
          else
            @parser.missing_option.call(flag) if raise_if_missing
          end
        else
          value = arg[2..-1]
          @parser.missing_option.call(flag) if raise_if_missing && value.empty?
          block.call value
        end
      end
    end

    private def args_size
      @double_dash_index || @args.size
    end

    private def args_index(flag=nil, &block)
      if block
        args_index_block(&block)
      elsif flag
        #args_index_flag(flag)
        args_index_block {|arg| arg == flag}
      end
    end

    private def args_index_flag(flag)
      args_index { |arg| arg == flag }
    end

    private def args_index_block(flag=nil,&block)
      index = @args.index { |arg| yield arg }
      if index
        if (double_dash_index = @double_dash_index) && index >= double_dash_index
          return nil
        end
      end
      index
    end

    private def delete_arg_at_index(index)
      arg = @args.delete_at(index)
      decrement_double_dash_index
      arg
    end

    private def decrement_double_dash_index
      if double_dash_index = @double_dash_index
        @double_dash_index = double_dash_index - 1
      end
    end

    private def check_invalid_options
      @args.each_with_index do |arg, index|
        return if (double_dash_index = @double_dash_index) && index >= double_dash_index

        if arg.starts_with?('-') && arg != "-"
          @parser.invalid_option.call(arg)
        end
      end
    end
  end


end