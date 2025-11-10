# frozen_string_literal: true

require "test_helper"

class CollectionTest < Minitest::Test
  TestRec = Struct.new(:a, :b)

  def test_enumerable_and_accessors
    c = FrigateRb::Collection.new([TestRec.new(1, 2), TestRec.new(3, 4)])
    assert_equal 2, c.size
    assert_equal [1, 3], c.pluck(:a)
    assert_equal [[1, 2], [3, 4]], c.pluck(:a, :b)
    refute c.empty?
    assert_equal 2, c[0].b
    assert_equal TestRec.new(3, 4), c.last
  end
end
