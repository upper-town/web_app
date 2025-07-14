# frozen_string_literal: true

require "test_helper"

class NormalizeNameKeyTest < ActiveSupport::TestCase
  let(:described_class) { NormalizeNameKey }

  test "#call" do
    [
      [nil,       nil],
      ["\n\t \n", ""],

      ["\n\t Some_\n  _name key!123\n", "some_name_key123"]
    ].each do |value, expected|
      returned = described_class.new(value).call

      assert(expected == returned, "Failed for #{value.inspect}")
    end
  end
end
