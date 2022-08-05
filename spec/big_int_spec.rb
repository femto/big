require "rspec"
require_relative "../big_int"

def it_converts_to_s(num, str, file = __FILE__, line = __LINE__, **opts)
  it file: file, line: line do
    num.to_s(**opts).should eq(str), file: file, line: line
    #String.build { |io| num.to_s(io, **opts) }.should eq(str), file: file, line: line
  end
end

describe "BigInt" do
  it "creates with a value of zero" do
    BigInt.new.to_s.should eq("0")
  end

  it "creates from signed ints" do
    BigInt.new(-1).to_s.should eq("-1")
    BigInt.new(-1).to_s.should eq("-1")
    BigInt.new(-1).to_s.should eq("-1")
    BigInt.new(-1).to_s.should eq("-1")
  end
end