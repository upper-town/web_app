# frozen_string_literal: true

require "test_helper"

class NormalizeInfoTest < ActiveSupport::TestCase
  let(:described_class) { NormalizeInfo }

  test "#call" do
    [
      [nil,       nil],
      ["\n\t \n", ""],

      ["\n\t Some\n  info\n", "Some\n  info"]
    ].each do |value, expected|
      returned = described_class.new(value).call

      assert(expected == returned, "Failed for #{value.inspect}")
    end
  end
end
