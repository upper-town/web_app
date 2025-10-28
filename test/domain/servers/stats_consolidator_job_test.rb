# frozen_string_literal: true

require "test_helper"

class Servers::StatsConsolidatorJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::StatsConsolidatorJob }

  describe "#perform" do
    it "calls service" do
      called = 0
      Servers::StatsConsolidator.stub(:call, ->(*) { called += 1 ; nil }) do
        described_class.new.perform
      end
      assert_equal(1, called)
    end
  end
end
