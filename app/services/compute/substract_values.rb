# frozen_string_literal: true

module Compute
  class SubstractValues
    attr_reader :left_values, :right_values

    def initialize(data)
      @left_values = data[0]['values']
      @right_values = data[1]['values']
    end

    # For performance reasons we substract in place in  left_values array here,
    # reducing dramatically amount of memory we allocate on large datasets
    def perform!
      left_values.each_with_index { |_, index| left_values[index] -= right_values[index] }
    end
  end
end
