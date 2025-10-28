# frozen_string_literal: true

require "test_helper"

class Servers::StatsPreviousConsolidatorJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::StatsPreviousConsolidatorJob }

  describe "#perform" do
    it "calls service with current_time from previous period" do
      current_time = Time.iso8601("2025-06-10T18:00:00Z")

      travel_to(current_time) do
        called = 0
        Servers::StatsConsolidator.stub(:call, ->(periods, time) do
          assert_equal(["week"], periods)
          assert_equal(Time.iso8601("2025-06-08T23:59:59.999999999Z"), time)
          called += 1
          nil
        end) do
          described_class.new.perform("week")
        end
        assert_equal(1, called)

        called = 0
        Servers::StatsConsolidator.stub(:call, ->(periods, time) do
          assert_equal(["month"], periods)
          assert_equal(Time.iso8601("2025-05-31T23:59:59.999999999Z"), time)
          called += 1
          nil
        end) do
          described_class.new.perform("month")
        end
        assert_equal(1, called)

        called = 0
        Servers::StatsConsolidator.stub(:call, ->(periods, time) do
          assert_equal(["year"], periods)
          assert_equal(Time.iso8601("2024-12-31T23:59:59.999999999Z"), time)
          called += 1
          nil
        end) do
          described_class.new.perform("year")
        end
        assert_equal(1, called)

        called = 0
        Servers::StatsConsolidator.stub(:call, ->(*) { called += 1 ; nil }) do
          error = assert_raises(StandardError) do
            described_class.new.perform("something_else")
          end
          assert_match(/invalid period: something_else/, error.message)
        end
        assert_equal(0, called)
      end
    end
  end
end
