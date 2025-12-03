# frozen_string_literal: true

module Philiprehberger
  module Result
    # Represents a failed result containing an error.
    class Err
      include Tappable
      include Filterable

      attr_reader :error

      # @param error the error value
      def initialize(error)
        @error = error
      end

      # @return [Boolean] false
      def ok? = false

      # @return [Boolean] true
      def err? = true

      # Ignore the value transformation.
      #
      # @return [Err] self
      def map
        self
      end

      # Ignore the chained operation.
      #
      # @return [Err] self
      def flat_map
        self
      end

      # Return the fallback value.
      #
      # @param default the fallback
      # @return the default value
      def unwrap_or(default) = default

      # Raise because there is no success value.
      #
      # @raise [UnwrapError] always
      def unwrap!
        raise UnwrapError, "Called unwrap! on Err(#{@error.inspect})"
      end

      # Return the error value.
      #
      # @return the error value
      def unwrap_err! = @error

      # Transform the error value.
      #
      # @yield [error] the current error
      # @return [Err] a new Err with the transformed error
      def map_err(&block)
        Err.new(block.call(@error))
      end

      # Recover from an error by calling the block.
      # The block should return a Result.
      #
      # @yield [error] the current error
      # @return [Ok, Err] the result of the block
      def or_else(&block)
        block.call(@error)
      end

      # Alias for flat_map (no-op on Err, returns self).
      alias and_then flat_map

      # Zip is a no-op on Err
      def zip(_other)
        self
      end

      # Return the default since there is no value to map.
      #
      # @param default the fallback value
      # @return the default
      def map_or(default, &)
        default
      end

      # Recover from specific error types
      def recover(error_class = nil)
        return self if error_class && !@error.is_a?(error_class)

        result = yield @error
        Result.ok(result)
      rescue StandardError => e
        Result.err(e)
      end

      # Serialize to a hash.
      #
      # @return [Hash]
      def to_h
        { err: @error }
      end

      # Pattern matching support via `in Err[error]`.
      #
      # @return [Array] deconstructed error
      def deconstruct
        [@error]
      end

      # Pattern matching support via `in Err(error:)`.
      #
      # @param keys [Array<Symbol>] requested keys
      # @return [Hash]
      def deconstruct_keys(_keys)
        { error: @error }
      end

      def ==(other)
        other.is_a?(Err) && other.error == @error
      end

      def to_s
        "Err(#{@error.inspect})"
      end

      alias inspect to_s
    end
  end
end
