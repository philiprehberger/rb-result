# frozen_string_literal: true

module Philiprehberger
  module Result
    # Filtering support for Ok and Err results.
    module Filterable
      # If Ok and predicate fails, convert to Err with the given error.
      # If already Err, pass through unchanged.
      #
      # @param error_fn [#call] callable returning the error value
      # @yield [value] predicate block receiving the success value
      # @return [Ok, Err]
      def filter(error_fn, &block)
        return self if err?
        return self if block.call(@value)

        Err.new(error_fn.call)
      end
    end
  end
end
