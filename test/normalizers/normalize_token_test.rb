# frozen_string_literal: true

require "test_helper"

class NormalizeTokenTest < ActiveSupport::TestCase
  let(:described_class) { NormalizeToken }

  describe "#call" do
    it "removes white spaces" do
      [
        [nil, nil],
        ["\n\t \n", ""],

        ["\n\t Aaaa1234 B  bbb 5678\n", "Aaaa1234Bbbb5678"]
      ].each do |value, expected|
        returned = described_class.new(value).call

        assert(expected == returned, "Failed for #{value.inspect}")
      end
    end
  end
end
