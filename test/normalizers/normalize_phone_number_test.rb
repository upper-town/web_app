# frozen_string_literal: true

require "test_helper"

class NormalizePhoneNumberTest < ActiveSupport::TestCase
  let(:described_class) { NormalizePhoneNumber }

  describe "#call" do
    it "tries to normalize phone number to international format" do
      [
        [nil, nil],
        ["\n\t \n", ""],

        ["202-555-9999",      "+12025559999"],
        ["(202) 555-9999",    "+12025559999"],
        ["(202)555-9999",     "+12025559999"],
        ["+1-202-555-9999",   "+12025559999"],
        ["+1 (202) 555-9999", "+12025559999"],
        ["+1(202)555-9999",   "+12025559999"],
        ["+12025559999",      "+12025559999"],

        ["16-95555-9999",       "+5516955559999"],
        ["(16) 95555-9999",     "+5516955559999"],
        ["(16)95555-9999",      "+5516955559999"],
        ["+55-16-95555-9999",   "+5516955559999"],
        ["+55 (16) 95555-9999", "+5516955559999"],
        ["+55(16)95555-9999",   "+5516955559999"],
        ["+5516955559999",      "+5516955559999"]
      ].each do |value, expected|
        returned = described_class.new(value).call

        assert(expected == returned, "Failed for #{value.inspect}")
      end
    end
  end
end
