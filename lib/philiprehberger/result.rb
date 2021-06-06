# frozen_string_literal: true

require_relative 'result/version'
require_relative 'result/tappable'
require_relative 'result/filterable'
require_relative 'result/ok'
require_relative 'result/err'

module Philiprehberger
  module Result
    class Error < StandardError; end

    # Raised when unwrap! is called on an Err.
    class UnwrapError < Error; end

    # Create a success result.
    #
    # @param value the success value
    # @return [Ok]
    def self.ok(value) = Ok.new(value)

    # Create a failure result.
    #
    # @param error the error value
    # @return [Err]
    def self.err(error) = Err.new(error)

    # Wrap a block, capturing exceptions as Err.
    #
    # @param exceptions [Array<Class>] exception classes to catch (default: StandardError)
    # @yield the block to execute
    # @return [Ok, Err]
    def self.try(*exceptions, &block)
      exceptions = [StandardError] if exceptions.empty?
      Ok.new(block.call)
    rescue *exceptions => e
      Err.new(e)
    end

    # Combine an array of results into a single result.
    #
    # @param results [Array<Ok, Err>] the results to combine
    # @return [Ok, Err] Ok with array of values, or Err with first error
    def self.all(results)
      values = []
      results.each do |result|
        return result if result.err?

        values << result.value
      end
      Ok.new(values)
    end
  end
end
