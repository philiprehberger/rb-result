# frozen_string_literal: true

module Philiprehberger
  module Result
    # Represents a successful result containing a value.
    class Ok
      include Tappable
      include Filterable

      attr_reader :value

      # @param value the success value
      def initialize(value)
        @value = value
      end

      # @return [Boolean] true
      def ok? = true

      # @return [Boolean] false
      def err? = false

      # Transform the success value.
      #
      # @yield [value] the current value
      # @return [Ok] a new Ok with the transformed value
      def map(&block)
        Ok.new(block.call(@value))
      end

      # Chain a result-returning operation.
      #
      # @yield [value] the current value
      # @return [Ok, Err] the result of the block
      def flat_map(&block)
        block.call(@value)
      end

      # Return the value or ignore the fallback.
      #
      # @param _default ignored
      # @return the success value
      def unwrap_or(_default) = @value

      # Return the value.
      #
      # @return the success value
      # @raise never
      def unwrap! = @value

      # Raise because Ok has no error to unwrap.
      #
      # @raise [UnwrapError] always
      def unwrap_err!
        raise UnwrapError, "Called unwrap_err! on Ok(#{@value.inspect})"
      end

      # Ignore the error transformation.
      #
      # @return [Ok] self
      def map_err
        self
      end

      # Return self (no error to recover from).
      #
      # @return [Ok] self
      def or_else
        self
      end

      # Alias for flat_map (Rust convention).
      alias and_then flat_map

      # Combine two Ok results into Ok([a, b])
      def zip(other)
        return other if other.err?

        Result.ok([@value, other.instance_variable_get(:@value)])
      end

      # Map the value with a fallback for Err.
      #
      # @param _default ignored
      # @yield [value] the current value
      # @return the result of the block
      def map_or(_default, &block)
        block.call(@value)
      end

      # Recovery is a no-op on Ok
      def recover(_error_class = nil)
        self
      end

      # Convert to a Maybe-like value: the success value, or nil for Err.
      #
      # @return the success value
      def to_maybe
        @value
      end

      # Check whether this Ok contains the given value (using ==).
      #
      # @param other the value to compare against
      # @return [Boolean] true if the value equals other
      def contains?(other)
        @value == other
      end

      # Always false on Ok (there is no error to compare).
      #
      # @param _other ignored
      # @return [Boolean] false
      def contains_err?(_other)
        false
      end

      # Serialize to a hash.
      #
      # @return [Hash]
      def to_h
        { ok: @value }
      end

      # Pattern matching support via `in Ok[value]`.
      #
      # @return [Array] deconstructed value
      def deconstruct
        [@value]
      end

      # Pattern matching support via `in Ok(value:)`.
      #
      # @param keys [Array<Symbol>] requested keys
      # @return [Hash]
      def deconstruct_keys(_keys)
        { value: @value }
      end

      def ==(other)
        other.is_a?(Ok) && other.value == @value
      end

      def to_s
        "Ok(#{@value.inspect})"
      end

      alias inspect to_s
    end
  end
end
