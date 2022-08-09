# frozen_string_literal: true

require 'tsort'
require 'test/unit'
require_relative 'top_sort'

class TSortHash < Hash # :nodoc:
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

class TSortArray < Array # :nodoc:
  include TSort
  alias tsort_each_node each_index
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

class TSortTest < Test::Unit::TestCase # :nodoc:
  def test_s_tsort
    #g = TSortHash[{1=>[2, 3], 2=>[4], 3=>[2, 4], 4=>[]}]
    g = TSortHash[{1=>[3, 2], 2=>[4], 3=>[4,2], 4=>[]}]
    each_node = lambda {|&b| g.each_key(&b) }
    each_child = lambda {|n, &b| g[n].each(&b) }
    assert_equal([4, 2, 3, 1], topsort(g))
    # g = {1=>[2], 2=>[3, 4], 3=>[2], 4=>[]}
    # assert_raise(TSort::Cyclic) { TSort.tsort(each_node, each_child) }
  end


end

