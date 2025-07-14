# frozen_string_literal: true

require "test_helper"

class NormalizeNameTest < ActiveSupport::TestCase
  let(:described_class) { NormalizeName }

  test "#call" do
    [
      [nil,       nil],
      ["\n\t \n", ""],

      ["\n\t Some\n  name\n", "Some name"]
    ].each do |value, expected|
      returned = described_class.new(value).call

      assert(expected == returned, "Failed for #{value.inspect}")
    end
  end
end
