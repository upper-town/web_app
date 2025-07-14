# frozen_string_literal: true

require "test_helper"

class NormalizeCodeTest < ActiveSupport::TestCase
  let(:described_class) { NormalizeCode }

  test "#call" do
    [
      [nil,       nil],
      ["\n\t \n", ""],

      ["\n\t Aa11 B  b2 2\n", "AA11BB22"]
    ].each do |value, expected|
      returned = described_class.new(value).call

      assert(expected == returned, "Failed for #{value.inspect}")
    end
  end
end
