# frozen_string_literal: true

require "test_helper"

class PeriodSelectOptionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { PeriodSelectOptionsQuery }

  describe "#call" do
    it "returns list of period options with label and value" do
      assert_equal(
        [
          ["Year",  "year"],
          ["Month", "month"],
          ["Week",  "week"]
        ],
        described_class.new.call
      )
    end
  end
end
