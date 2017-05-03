# frozen_string_literal: true

module Philiprehberger
  module Result
    # Side-effect methods for Ok and Err results.
    module Tappable
      # Execute a side-effect on Ok value without changing the result.
      #
      # @yield [value] the success value
      # @return [self]
      def tap_ok(&block)
        block.call(@value) if ok?
        self
      end

      # Execute a side-effect on Err without changing the result.
      #
      # @yield [error] the error value
      # @return [self]
      def tap_err(&block)
        block.call(@error) if err?
        self
      end
    end
  end
end
