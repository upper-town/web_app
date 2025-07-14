# frozen_string_literal: true

require "test_helper"

class NormalizeDescriptionTest < ActiveSupport::TestCase
  let(:described_class) { NormalizeDescription }

  test "#call" do
    [
      [nil,       nil],
      ["\n\t \n", ""],

      ["\n\t Some\n  description\n", "Some description"]
    ].each do |value, expected|
      returned = described_class.new(value).call

      assert(expected == returned, "Failed for #{value.inspect}")
    end
  end
end
