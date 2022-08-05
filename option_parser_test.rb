require 'minitest/autorun'
require './option_parser'
# 注意有些资料中，测试类不是继承自MiniTest::Test，
# 那是MiniTest 5之前的做法，MiniTest会通知你改正
class TestOptionParser < MiniTest::Test
  def setup
    @parser = OptionParser1.new do |parser|
      parser.banner = "Usage: salute [arguments]"
      parser.on("-u", "--upcase", "Upcases the salute") { upcase = true }
      parser.on("-t NAME", "--to=NAME", "Specifies the name to salute") { |name| destination = name }
      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit
      end
    end
  end
  def test_parse
    @parser
  end
  def teardown
  end
end