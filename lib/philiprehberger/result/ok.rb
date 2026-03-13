# frozen_string_literal: true

module Philiprehberger
  module Result
    # Represents a successful result containing a value.
    class Ok
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
