# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Result do
  it 'has a version number' do
    expect(Philiprehberger::Result::VERSION).not_to be_nil
  end

  describe '.ok' do
    it 'creates an Ok result' do
      result = described_class.ok(42)
      expect(result).to be_a(Philiprehberger::Result::Ok)
      expect(result.value).to eq(42)
    end
  end

  describe '.err' do
    it 'creates an Err result' do
      result = described_class.err('fail')
      expect(result).to be_a(Philiprehberger::Result::Err)
      expect(result.error).to eq('fail')
    end
  end

  describe '.try' do
    it 'wraps a successful block in Ok' do
      result = described_class.try { 42 }
      expect(result).to eq(Philiprehberger::Result::Ok.new(42))
    end

    it 'wraps an exception in Err' do
      result = described_class.try { raise StandardError, 'boom' }
      expect(result).to be_a(Philiprehberger::Result::Err)
      expect(result.error).to be_a(StandardError)
      expect(result.error.message).to eq('boom')
    end

    it 'catches only specified exceptions' do
      expect do
        described_class.try(ArgumentError) { raise 'wrong' }
      end.to raise_error(RuntimeError)
    end

    it 'catches multiple specified exception classes' do
      result = described_class.try(ArgumentError, TypeError) { raise TypeError, 'bad type' }
      expect(result).to be_a(Philiprehberger::Result::Err)
      expect(result.error).to be_a(TypeError)
    end
  end

  describe '.all' do
    it 'returns Ok with array of values when all are Ok' do
      results = [described_class.ok(1), described_class.ok(2), described_class.ok(3)]
      result = described_class.all(results)
      expect(result).to eq(Philiprehberger::Result::Ok.new([1, 2, 3]))
    end

    it 'returns Err with first error when any is Err' do
      results = [described_class.ok(1), described_class.err('fail'), described_class.ok(3)]
      result = described_class.all(results)
      expect(result).to eq(Philiprehberger::Result::Err.new('fail'))
    end

    it 'returns first Err when multiple are Err' do
      results = [described_class.err('first'), described_class.err('second')]
      result = described_class.all(results)
      expect(result).to eq(Philiprehberger::Result::Err.new('first'))
    end

    it 'returns Ok with empty array for empty input' do
      result = described_class.all([])
      expect(result).to eq(Philiprehberger::Result::Ok.new([]))
    end
  end

  describe 'chaining' do
    it 'chains multiple map calls' do
      result = described_class.ok(2).map { |v| v * 3 }.map { |v| v + 1 }
      expect(result).to eq(Philiprehberger::Result::Ok.new(7))
    end

    it 'chains multiple flat_map calls' do
      result = described_class.ok(5)
                              .flat_map { |v| described_class.ok(v * 2) }
                              .flat_map { |v| described_class.ok(v + 1) }
      expect(result).to eq(Philiprehberger::Result::Ok.new(11))
    end

    it 'short-circuits on Err in a chain' do
      result = described_class.ok(5)
                              .flat_map { |_v| described_class.err('fail') }
                              .map { |v| v + 1 }
      expect(result).to eq(Philiprehberger::Result::Err.new('fail'))
    end
  end
end

RSpec.describe Philiprehberger::Result::Ok do
  subject(:ok) { described_class.new(42) }

  it 'is ok' do
    expect(ok.ok?).to be true
    expect(ok.err?).to be false
  end

  describe '#map' do
    it 'transforms the value' do
      result = ok.map { |v| v * 2 }
      expect(result).to eq(described_class.new(84))
    end
  end

  describe '#flat_map' do
    it 'chains result-returning operations' do
      result = ok.flat_map { |v| described_class.new(v + 1) }
      expect(result).to eq(described_class.new(43))
    end
  end

  describe '#unwrap!' do
    it 'returns the value' do
      expect(ok.unwrap!).to eq(42)
    end
  end

  describe '#unwrap_or' do
    it 'returns the value, ignoring the default' do
      expect(ok.unwrap_or(0)).to eq(42)
    end
  end

  describe '#map_err' do
    it 'returns self' do
      expect(ok.map_err { |e| e }).to equal(ok)
    end
  end

  describe '#tap_ok' do
    it 'executes the block with the value' do
      tapped = nil
      ok.tap_ok { |v| tapped = v }
      expect(tapped).to eq(42)
    end

    it 'returns self' do
      result = ok.tap_ok { |_v| nil }
      expect(result).to equal(ok)
    end
  end

  describe '#tap_err' do
    it 'does not execute the block' do
      called = false
      ok.tap_err { |_e| called = true }
      expect(called).to be false
    end

    it 'returns self' do
      result = ok.tap_err { |_e| nil }
      expect(result).to equal(ok)
    end
  end

  describe '#filter' do
    it 'returns self when predicate passes' do
      result = ok.filter(-> { 'too small' }) { |v| v > 0 }
      expect(result).to equal(ok)
    end

    it 'returns Err when predicate fails' do
      result = ok.filter(-> { 'must be negative' }) { |v| v < 0 }
      expect(result).to eq(Philiprehberger::Result::Err.new('must be negative'))
    end
  end

  describe '#or_else' do
    it 'returns self without calling the block' do
      called = false
      result = ok.or_else { called = true }
      expect(result).to equal(ok)
      expect(called).to be false
    end
  end

  describe '#and_then' do
    it 'behaves like flat_map' do
      result = ok.and_then { |v| described_class.new(v + 1) }
      expect(result).to eq(described_class.new(43))
    end
  end

  describe '#to_h' do
    it 'returns a hash with the ok key' do
      expect(ok.to_h).to eq({ ok: 42 })
    end
  end

  describe '#to_s' do
    it 'returns a readable representation' do
      expect(ok.to_s).to eq('Ok(42)')
    end

    it 'handles nil value' do
      expect(described_class.new(nil).to_s).to eq('Ok(nil)')
    end
  end

  describe '#inspect' do
    it 'is aliased to to_s' do
      expect(ok.inspect).to eq(ok.to_s)
    end
  end

  describe '#==' do
    it 'is equal to another Ok with the same value' do
      expect(ok).to eq(described_class.new(42))
    end

    it 'is not equal to an Ok with a different value' do
      expect(ok).not_to eq(described_class.new(99))
    end

    it 'is not equal to an Err with the same inner value' do
      expect(described_class.new('x')).not_to eq(Philiprehberger::Result::Err.new('x'))
    end

    it 'is not equal to a non-Result object with the same value' do
      expect(ok).not_to eq(42)
    end
  end

  describe 'nil value' do
    subject(:ok_nil) { described_class.new(nil) }

    it 'stores nil as a valid value' do
      expect(ok_nil.value).to be_nil
      expect(ok_nil.ok?).to be true
    end

    it 'maps over nil' do
      result = ok_nil.map { |v| v.nil? ? 'was nil' : 'not nil' }
      expect(result).to eq(described_class.new('was nil'))
    end

    it 'unwraps nil' do
      expect(ok_nil.unwrap!).to be_nil
    end

    it 'returns nil from unwrap_or instead of default' do
      expect(ok_nil.unwrap_or('default')).to be_nil
    end

    it 'serializes nil to hash' do
      expect(ok_nil.to_h).to eq({ ok: nil })
    end
  end

  describe 'pattern matching' do
    it 'supports deconstruct' do
      case ok
      in [value]
        expect(value).to eq(42)
      end
    end

    it 'supports deconstruct_keys' do
      case ok
      in { value: v }
        expect(v).to eq(42)
      end
    end

    it 'distinguishes Ok from Err in a case expression' do
      matched = case ok
                in Philiprehberger::Result::Ok[value]
                  "ok:#{value}"
                in Philiprehberger::Result::Err[error]
                  "err:#{error}"
                end
      expect(matched).to eq('ok:42')
    end
  end

  describe '#unwrap_err!' do
    it 'raises UnwrapError' do
      expect { ok.unwrap_err! }.to raise_error(Philiprehberger::Result::UnwrapError)
    end

    it 'includes the value in the exception message' do
      expect { ok.unwrap_err! }.to raise_error(/42/)
    end
  end

  describe '#map_or' do
    it 'applies the block to the value' do
      expect(ok.map_or(0) { |v| v * 2 }).to eq(84)
    end

    it 'ignores the default' do
      expect(ok.map_or('default') { |v| v }).to eq(42)
    end
  end

  describe '#flat_map returning Err' do
    it 'converts Ok to Err when flat_map block returns Err' do
      result = ok.flat_map { |_v| Philiprehberger::Result::Err.new('went wrong') }
      expect(result).to be_a(Philiprehberger::Result::Err)
      expect(result.error).to eq('went wrong')
    end
  end

  describe '#filter with nil value' do
    it 'evaluates predicate against nil' do
      ok_nil = described_class.new(nil)
      result = ok_nil.filter(-> { 'was nil' }, &:nil?)
      expect(result).to equal(ok_nil)
    end

    it 'converts to Err when nil fails predicate' do
      ok_nil = described_class.new(nil)
      result = ok_nil.filter(-> { 'expected non-nil' }) { |v| !v.nil? }
      expect(result).to eq(Philiprehberger::Result::Err.new('expected non-nil'))
    end
  end

  describe '#tap_ok chaining' do
    it 'allows chaining tap_ok with map' do
      log = []
      result = ok.tap_ok { |v| log << v }.map { |v| v + 1 }.tap_ok { |v| log << v }
      expect(result).to eq(described_class.new(43))
      expect(log).to eq([42, 43])
    end
  end
end

RSpec.describe Philiprehberger::Result::Err do
  subject(:err) { described_class.new('not found') }

  it 'is err' do
    expect(err.ok?).to be false
    expect(err.err?).to be true
  end

  describe '#map' do
    it 'returns self' do
      result = err.map { |v| v * 2 }
      expect(result).to equal(err)
    end
  end

  describe '#flat_map' do
    it 'returns self' do
      result = err.flat_map { |v| Philiprehberger::Result::Ok.new(v) }
      expect(result).to equal(err)
    end
  end

  describe '#unwrap_or' do
    it 'returns the default' do
      expect(err.unwrap_or(0)).to eq(0)
    end
  end

  describe '#map_err' do
    it 'transforms the error' do
      result = err.map_err(&:upcase)
      expect(result).to eq(described_class.new('NOT FOUND'))
    end
  end

  describe '#tap_ok' do
    it 'does not execute the block' do
      called = false
      err.tap_ok { |_v| called = true }
      expect(called).to be false
    end

    it 'returns self' do
      result = err.tap_ok { |_v| nil }
      expect(result).to equal(err)
    end
  end

  describe '#tap_err' do
    it 'executes the block with the error' do
      tapped = nil
      err.tap_err { |e| tapped = e }
      expect(tapped).to eq('not found')
    end

    it 'returns self' do
      result = err.tap_err { |_e| nil }
      expect(result).to equal(err)
    end
  end

  describe '#filter' do
    it 'returns self without evaluating the predicate' do
      called = false
      result = err.filter(-> { 'unused' }) { |_v| called = true }
      expect(result).to equal(err)
      expect(called).to be false
    end
  end

  describe '#or_else' do
    it 'calls the block with the error for recovery' do
      result = err.or_else { |e| Philiprehberger::Result::Ok.new("recovered: #{e}") }
      expect(result).to eq(Philiprehberger::Result::Ok.new('recovered: not found'))
    end

    it 'can return another Err' do
      result = err.or_else { |e| described_class.new("wrapped: #{e}") }
      expect(result).to eq(described_class.new('wrapped: not found'))
    end
  end

  describe '#and_then' do
    it 'returns self without calling the block' do
      called = false
      result = err.and_then { called = true }
      expect(result).to equal(err)
      expect(called).to be false
    end
  end

  describe '#to_h' do
    it 'returns a hash with the err key' do
      expect(err.to_h).to eq({ err: 'not found' })
    end
  end

  describe '#==' do
    it 'is equal to another Err with the same error' do
      expect(err).to eq(described_class.new('not found'))
    end

    it 'is not equal to an Err with a different error' do
      expect(err).not_to eq(described_class.new('other error'))
    end

    it 'is not equal to an Ok with the same inner value' do
      expect(described_class.new('x')).not_to eq(Philiprehberger::Result::Ok.new('x'))
    end

    it 'is not equal to a non-Result object with the same value' do
      expect(err).not_to eq('not found')
    end
  end

  describe '#to_s' do
    it 'returns a readable representation' do
      expect(err.to_s).to eq('Err("not found")')
    end

    it 'handles nil error' do
      expect(described_class.new(nil).to_s).to eq('Err(nil)')
    end
  end

  describe '#inspect' do
    it 'is aliased to to_s' do
      expect(err.inspect).to eq(err.to_s)
    end
  end

  describe '#unwrap!' do
    it 'raises UnwrapError' do
      expect { err.unwrap! }.to raise_error(Philiprehberger::Result::UnwrapError)
    end

    it 'includes the error value in the exception message' do
      expect { err.unwrap! }.to raise_error(/not found/)
    end
  end

  describe 'nil error' do
    subject(:err_nil) { described_class.new(nil) }

    it 'stores nil as a valid error' do
      expect(err_nil.error).to be_nil
      expect(err_nil.err?).to be true
    end

    it 'maps over nil error' do
      result = err_nil.map_err { |e| e.nil? ? 'was nil' : 'not nil' }
      expect(result).to eq(described_class.new('was nil'))
    end

    it 'serializes nil error to hash' do
      expect(err_nil.to_h).to eq({ err: nil })
    end

    it 'unwrap_or returns default when error is nil' do
      expect(err_nil.unwrap_or('fallback')).to eq('fallback')
    end
  end

  describe '#unwrap_err!' do
    it 'returns the error value' do
      expect(err.unwrap_err!).to eq('not found')
    end
  end

  describe '#map_or' do
    it 'returns the default' do
      expect(err.map_or(0) { |v| v * 2 }).to eq(0)
    end
  end

  describe '#or_else chaining' do
    it 'chains multiple or_else calls until recovery succeeds' do
      result = err
               .or_else { |_e| described_class.new('still failing') }
               .or_else { |_e| Philiprehberger::Result::Ok.new('recovered') }
      expect(result).to eq(Philiprehberger::Result::Ok.new('recovered'))
    end
  end

  describe '#tap_err chaining' do
    it 'allows chaining tap_err with map_err' do
      log = []
      result = err.tap_err { |e| log << e }.map_err(&:upcase).tap_err { |e| log << e }
      expect(result).to eq(described_class.new('NOT FOUND'))
      expect(log).to eq(['not found', 'NOT FOUND'])
    end
  end

  describe 'pattern matching' do
    it 'supports deconstruct' do
      case err
      in [error]
        expect(error).to eq('not found')
      end
    end

    it 'supports deconstruct_keys' do
      case err
      in { error: e }
        expect(e).to eq('not found')
      end
    end

    it 'distinguishes Err from Ok in a case expression' do
      matched = case err
                in Philiprehberger::Result::Ok[value]
                  "ok:#{value}"
                in Philiprehberger::Result::Err[error]
                  "err:#{error}"
                end
      expect(matched).to eq('err:not found')
    end
  end
end

RSpec.describe 'monadic composition' do
  let(:parse_int) do
    lambda do |str|
      Integer(str)
      Philiprehberger::Result::Ok.new(Integer(str))
    rescue ArgumentError
      Philiprehberger::Result::Err.new("not a number: #{str}")
    end
  end

  let(:safe_div) do
    lambda do |a, b|
      return Philiprehberger::Result::Err.new('division by zero') if b.zero?

      Philiprehberger::Result::Ok.new(a / b)
    end
  end

  it 'composes parse and divide via flat_map chain' do
    result = parse_int.call('10')
                      .flat_map { |n| safe_div.call(n, 2) }
    expect(result).to eq(Philiprehberger::Result::Ok.new(5))
  end

  it 'short-circuits on parse failure' do
    result = parse_int.call('abc')
                      .flat_map { |n| safe_div.call(n, 2) }
    expect(result).to eq(Philiprehberger::Result::Err.new('not a number: abc'))
  end

  it 'short-circuits on division by zero' do
    result = parse_int.call('10')
                      .flat_map { |n| safe_div.call(n, 0) }
    expect(result).to eq(Philiprehberger::Result::Err.new('division by zero'))
  end

  it 'recovers from error with or_else then continues with flat_map' do
    result = parse_int.call('abc')
                      .or_else { |_e| Philiprehberger::Result::Ok.new(0) }
                      .flat_map do |n|
  safe_div.call(n + 10,
                2)
end
    expect(result).to eq(Philiprehberger::Result::Ok.new(5))
  end
end

RSpec.describe Philiprehberger::Result do
  describe '.flatten' do
    it 'flattens Ok(Ok(v)) to Ok(v)' do
      nested = described_class.ok(described_class.ok(42))
      result = described_class.flatten(nested)
      expect(result).to eq(Philiprehberger::Result::Ok.new(42))
    end

    it 'flattens Ok(Err(e)) to Err(e)' do
      nested = described_class.ok(described_class.err('fail'))
      result = described_class.flatten(nested)
      expect(result).to eq(Philiprehberger::Result::Err.new('fail'))
    end

    it 'passes through Err unchanged' do
      err = described_class.err('fail')
      expect(described_class.flatten(err)).to equal(err)
    end

    it 'returns non-nested Ok unchanged' do
      ok = described_class.ok(42)
      expect(described_class.flatten(ok)).to equal(ok)
    end
  end

  describe '.any' do
    it 'returns the first Ok' do
      results = [described_class.err('a'), described_class.ok(1), described_class.ok(2)]
      expect(described_class.any(results).unwrap!).to eq(1)
    end

    it 'returns Err with all errors when all fail' do
      results = [described_class.err('a'), described_class.err('b')]
      result = described_class.any(results)
      expect(result.err?).to be true
    end

    it 'returns first Ok immediately' do
      results = [described_class.ok(42)]
      expect(described_class.any(results).unwrap!).to eq(42)
    end
  end

  describe '#zip' do
    it 'combines two Ok values' do
      a = described_class.ok(1)
      b = described_class.ok(2)
      result = a.zip(b)
      expect(result.ok?).to be true
      expect(result.unwrap!).to eq([1, 2])
    end

    it 'returns Err if first is Err' do
      a = described_class.err('fail')
      b = described_class.ok(2)
      expect(a.zip(b).err?).to be true
    end

    it 'returns Err if second is Err' do
      a = described_class.ok(1)
      b = described_class.err('fail')
      expect(a.zip(b).err?).to be true
    end
  end

  describe '#recover' do
    it 'is no-op on Ok' do
      result = described_class.ok(42).recover { |_| 0 }
      expect(result.unwrap!).to eq(42)
    end

    it 'recovers from Err' do
      result = described_class.err(StandardError.new('boom')).recover { |e| "fixed: #{e.message}" }
      expect(result.ok?).to be true
      expect(result.unwrap!).to eq('fixed: boom')
    end

    it 'filters by error class' do
      result = described_class.err(ArgumentError.new('bad')).recover(TypeError) { |_| 'fixed' }
      expect(result.err?).to be true
    end

    it 'recovers when error class matches' do
      result = described_class.err(ArgumentError.new('bad')).recover(ArgumentError) { |_| 'fixed' }
      expect(result.ok?).to be true
    end
  end
end
