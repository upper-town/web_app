# frozen_string_literal: true

require "test_helper"

class NormalizeEmailTest < ActiveSupport::TestCase
  let(:described_class) { NormalizeEmail }

  describe "#call" do
    it "just removes white spaces and transforms to lower case" do
      [
        [nil, nil],
        ["\n\t \n", ""],

        ["user@example.com",      "user@example.com"],
        ["  USER@example .COM  ", "user@example.com"],
        [" 1! @# user @ example .COM.net...(ORG)  ", "1!@#user@example.com.net...(org)"]
      ].each do |value, expected|
        returned = described_class.new(value).call

        assert(expected == returned, "Failed for #{value.inspect}")
      end
    end
  end
end
