# frozen_string_literal: true

module FrigateRb
  # this class provides convenience methods to collections of types returned from
  # the API, this is similar to ActiveRecord
  class Collection
    include Enumerable

    def initialize(records = [])
      @records = Array(records)
    end

    # Required by Enumerable
    def each(&block)
      @records.each(&block)
    end

    def pluck(*attribute_names)
      if attribute_names.size > 1
        @records.map do |record|
          attribute_names.map { |attr| record.send(attr.to_s) }
        end
      else
        attr = attribute_names.first.to_s
        @records.map { |record| record.send(attr) }
      end
    end

    def size
      @records.size
    end

    def empty?
      @records.empty?
    end

    def [](index)
      @records[index]
    end

    def last(len = nil)
      @records.last(len)
    end
  end
end
