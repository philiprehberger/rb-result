# frozen_string_literal: true

require "spec_helper"

RSpec.describe Philiprehberger::Result do
  it "has a version number" do
    expect(Philiprehberger::Result::VERSION).not_to be_nil
  end

  describe ".ok" do
    it "creates an Ok result" do
      result = described_class.ok(42)
      expect(result).to be_a(Philiprehberger::Result::Ok)
      expect(result.value).to eq(42)
    end
  end

  describe ".err" do
    it "creates an Err result" do
      result = described_class.err("fail")
      expect(result).to be_a(Philiprehberger::Result::Err)
      expect(result.error).to eq("fail")
    end
  end

  describe ".try" do
    it "wraps a successful block in Ok" do
      result = described_class.try { 42 }
      expect(result).to eq(Philiprehberger::Result::Ok.new(42))
    end

    it "wraps an exception in Err" do
      result = described_class.try { raise StandardError, "boom" }
      expect(result).to be_a(Philiprehberger::Result::Err)
      expect(result.error).to be_a(StandardError)
      expect(result.error.message).to eq("boom")
    end

    it "catches only specified exceptions" do
      expect do
        described_class.try(ArgumentError) { raise "wrong" }
      end.to raise_error(RuntimeError)
    end
  end
end

RSpec.describe Philiprehberger::Result::Ok do
  subject(:ok) { described_class.new(42) }

  it "is ok" do
    expect(ok.ok?).to be true
    expect(ok.err?).to be false
  end

  describe "#map" do
    it "transforms the value" do
      result = ok.map { |v| v * 2 }
      expect(result).to eq(described_class.new(84))
    end
  end

  describe "#flat_map" do
    it "chains result-returning operations" do
      result = ok.flat_map { |v| described_class.new(v + 1) }
      expect(result).to eq(described_class.new(43))
    end
  end

  describe "#unwrap!" do
    it "returns the value" do
      expect(ok.unwrap!).to eq(42)
    end
  end

  describe "#unwrap_or" do
    it "returns the value, ignoring the default" do
      expect(ok.unwrap_or(0)).to eq(42)
    end
  end

  describe "#map_err" do
    it "returns self" do
      expect(ok.map_err { |e| e }).to equal(ok)
    end
  end

  describe "#==" do
    it "is equal to another Ok with the same value" do
      expect(ok).to eq(described_class.new(42))
    end

    it "is not equal to an Ok with a different value" do
      expect(ok).not_to eq(described_class.new(99))
    end
  end

  describe "#to_s" do
    it "returns a readable representation" do
      expect(ok.to_s).to eq("Ok(42)")
    end
  end

  describe "pattern matching" do
    it "supports deconstruct" do
      case ok
      in [value]
        expect(value).to eq(42)
      end
    end

    it "supports deconstruct_keys" do
      case ok
      in { value: v }
        expect(v).to eq(42)
      end
    end
  end
end

RSpec.describe Philiprehberger::Result::Err do
  subject(:err) { described_class.new("not found") }

  it "is err" do
    expect(err.ok?).to be false
    expect(err.err?).to be true
  end

  describe "#map" do
    it "returns self" do
      result = err.map { |v| v * 2 }
      expect(result).to equal(err)
    end
  end

  describe "#flat_map" do
    it "returns self" do
      result = err.flat_map { |v| Philiprehberger::Result::Ok.new(v) }
      expect(result).to equal(err)
    end
  end

  describe "#unwrap!" do
    it "raises UnwrapError" do
      expect { err.unwrap! }.to raise_error(Philiprehberger::Result::UnwrapError)
    end
  end

  describe "#unwrap_or" do
    it "returns the default" do
      expect(err.unwrap_or(0)).to eq(0)
    end
  end

  describe "#map_err" do
    it "transforms the error" do
      result = err.map_err(&:upcase)
      expect(result).to eq(described_class.new("NOT FOUND"))
    end
  end

  describe "#==" do
    it "is equal to another Err with the same error" do
      expect(err).to eq(described_class.new("not found"))
    end
  end

  describe "#to_s" do
    it "returns a readable representation" do
      expect(err.to_s).to eq('Err("not found")')
    end
  end

  describe "pattern matching" do
    it "supports deconstruct" do
      case err
      in [error]
        expect(error).to eq("not found")
      end
    end

    it "supports deconstruct_keys" do
      case err
      in { error: e }
        expect(e).to eq("not found")
      end
    end
  end
end
