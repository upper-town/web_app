# frozen_string_literal: true

require "test_helper"

class PeriodsTest < ActiveSupport::TestCase
  let(:described_class) { Periods }

  describe "min_past_time" do
    it "parses and returns from env var" do
      env_with_values("PERIODS_MIN_PAST_TIME" => "2024-01-01T00:00:00Z") do
        min_past_time = described_class.min_past_time

        assert_equal(Time.iso8601("2024-01-01T00:00:00Z"), min_past_time)
      end
    end
  end

  describe "reference_date_for" do
    describe "when period is year" do
      it "returns the end_of_year date in UTC" do
        reference_date = described_class.reference_date_for(
          "year", Time.iso8601("2024-12-31T21:00:00-03")
        )

        assert_equal(Date.iso8601("2025-12-31"), reference_date)
      end
    end

    describe "when period is month" do
      it "returns the end_of_month date in UTC" do
        reference_date = described_class.reference_date_for(
          "month", Time.iso8601("2024-08-31T21:00:00-03")
        )

        assert_equal(Date.iso8601("2024-09-30"), reference_date)
      end
    end

    describe "when period is week" do
      it "returns the end_of_week date in UTC" do
        reference_date = described_class.reference_date_for(
          "week", Time.iso8601("2024-09-01T21:00:00-03")
        )

        assert_equal(Date.iso8601("2024-09-08"), reference_date)
      end
    end

    describe "when period is something else" do
      it "raises an error" do
        error = assert_raises(StandardError) do
          described_class.reference_date_for("something_else", Time.current)
        end

        assert_match(/Invalid period for Periods.reference_date_for/, error.message)
      end
    end
  end

  describe "reference_range_for" do
    describe "when period is year" do
      it "returns all_year range in UTC" do
        reference_range = described_class.reference_range_for(
          "year", Time.iso8601("2024-12-31T21:00:00-03")
        )

        assert_equal(
          Time.iso8601("2025-01-01T00:00:00Z")..Time.iso8601("2025-12-31T23:59:59.999999999Z"),
          reference_range
        )
      end
    end

    describe "when period is month" do
      it "returns all_month date in UTC" do
        reference_range = described_class.reference_range_for(
          "month", Time.iso8601("2024-08-31T21:00:00-03")
        )

        assert_equal(
          Time.iso8601("2024-09-01T00:00:00Z")..Time.iso8601("2024-09-30T23:59:59.999999999Z"),
          reference_range
        )
      end
    end

    describe "when period is week" do
      it "returns the end_of_week date in UTC" do
        reference_range = described_class.reference_range_for(
          "week", Time.iso8601("2024-09-01T21:00:00-03")
        )

        assert_equal(
          Time.iso8601("2024-09-02T00:00:00Z")..Time.iso8601("2024-09-08T23:59:59.999999999Z"),
          reference_range
        )
      end
    end

    describe "when period is something else" do
      it "raises an error" do
        error = assert_raises(StandardError) do
          described_class.reference_range_for("something_else", Time.current)
        end

        assert_match(/Invalid period for Periods.reference_range_for/, error.message)
      end
    end
  end

  describe "next_time_for" do
    describe "when period is year" do
      it "returns the beginning of next_year time in UTC" do
        reference_date = described_class.next_time_for(
          "year", Time.iso8601("2024-12-31T21:00:00-03")
        )

        assert_equal(Time.iso8601("2026-01-01T00:00:00Z"), reference_date)
      end
    end

    describe "when period is month" do
      it "returns the beginning of next_month time in UTC" do
        reference_date = described_class.next_time_for(
          "month", Time.iso8601("2024-08-31T21:00:00-03")
        )

        assert_equal(Time.iso8601("2024-10-01T00:00:00Z"), reference_date)
      end
    end

    describe "when period is week" do
      it "returns the beginning of next_week time in UTC" do
        reference_date = described_class.next_time_for(
          "week", Time.iso8601("2024-09-01T21:00:00-03")
        )

        assert_equal(Time.iso8601("2024-09-09T00:00:00Z"), reference_date)
      end
    end

    describe "when period is something else" do
      it "raises an error" do
        error = assert_raises(StandardError) do
          described_class.next_time_for("something_else", Time.current)
        end

        assert_match(/Invalid period for Periods.next_time_for/, error.message)
      end
    end
  end

  describe "loop_through" do
    def around_loop_through(&)
      env_with_values("PERIODS_MIN_PAST_TIME" => "2024-01-01T00:00:00Z", &)
    end

    describe "when past_time is greater than current_time" do
      it "raises an error" do
        around_loop_through do
          freeze_time do
            error = assert_raises(StandardError) do
              described_class.loop_through("year", Time.current, 1.second.ago)
            end

            assert_match(/Invalid past_time or current_time for Periods.loop_through/, error.message)
          end
        end
      end
    end

    describe "when period is year" do
      it "yields all reference_date and reference_range years in UTC between past_time and current_time" do
        around_loop_through do
          yielded_args = []

          described_class.loop_through(
            "year",
            Time.iso8601("2024-12-31T21:00:00-03"),
            Time.iso8601("2027-08-31T21:00:00-03")
          ) do |*args|
            yielded_args << args
          end

          assert_equal(
            [
              [
                Date.iso8601("2025-12-31"),
                Time.iso8601("2025-01-01T00:00:00Z")..Time.iso8601("2025-12-31T23:59:59.999999999Z")
              ],
              [
                Date.iso8601("2026-12-31"),
                Time.iso8601("2026-01-01T00:00:00Z")..Time.iso8601("2026-12-31T23:59:59.999999999Z")
              ],
              [
                Date.iso8601("2027-12-31"),
                Time.iso8601("2027-01-01T00:00:00Z")..Time.iso8601("2027-12-31T23:59:59.999999999Z")
              ]
            ],
            yielded_args
          )
        end
      end
    end

    describe "when period is month" do
      it "yields all reference_date and reference_range months in UTC between past_time and current_time" do
        around_loop_through do
          yielded_args = []

          described_class.loop_through(
            "month",
            Time.iso8601("2024-09-30T21:00:00-03"),
            Time.iso8601("2024-12-31T21:00:00-03")
          ) do |*args|
            yielded_args << args
          end

          assert_equal(
            [
              [
                Date.iso8601("2024-10-31"),
                Time.iso8601("2024-10-01T00:00:00Z")..Time.iso8601("2024-10-31T23:59:59.999999999Z")
              ],
              [
                Date.iso8601("2024-11-30"),
                Time.iso8601("2024-11-01T00:00:00Z")..Time.iso8601("2024-11-30T23:59:59.999999999Z")
              ],
              [
                Date.iso8601("2024-12-31"),
                Time.iso8601("2024-12-01T00:00:00Z")..Time.iso8601("2024-12-31T23:59:59.999999999Z")
              ],
              [
                Date.iso8601("2025-01-31"),
                Time.iso8601("2025-01-01T00:00:00Z")..Time.iso8601("2025-01-31T23:59:59.999999999Z")
              ]
            ],
            yielded_args
          )
        end
      end
    end

    describe "when period is week" do
      it "yields all reference_date and reference_range weeks in UTC between past_time and current_time" do
        around_loop_through do
          yielded_args = []

          described_class.loop_through(
            "week",
            Time.iso8601("2024-09-01T21:00:00-03"),
            Time.iso8601("2024-09-22T21:00:00-03")
          ) do |*args|
            yielded_args << args
          end

          assert_equal(
            [
              [
                Date.iso8601("2024-09-08"),
                Time.iso8601("2024-09-02T00:00:00Z")..Time.iso8601("2024-09-08T23:59:59.999999999Z")
              ],
              [
                Date.iso8601("2024-09-15"),
                Time.iso8601("2024-09-09T00:00:00Z")..Time.iso8601("2024-09-15T23:59:59.999999999Z")
              ],
              [
                Date.iso8601("2024-09-22"),
                Time.iso8601("2024-09-16T00:00:00Z")..Time.iso8601("2024-09-22T23:59:59.999999999Z")
              ],
              [
                Date.iso8601("2024-09-29"),
                Time.iso8601("2024-09-23T00:00:00Z")..Time.iso8601("2024-09-29T23:59:59.999999999Z")
              ]
            ],
            yielded_args
          )
        end
      end
    end

    describe "default values and fallbacks" do
      describe "when past_time is nil" do
        it "falls back to Time.current" do
          travel_to("2024-06-15T00:00:00Z") do
            around_loop_through do
              yielded_args = []

              described_class.loop_through(
                "year",
                nil,
                Time.iso8601("2025-08-31T21:00:00-03")
              ) do |*args|
                yielded_args << args
              end

              assert_equal(
                [
                  [
                    Date.iso8601("2024-12-31"),
                    Time.iso8601("2024-01-01T00:00:00Z")..Time.iso8601("2024-12-31T23:59:59.999999999Z")
                  ],
                  [
                    Date.iso8601("2025-12-31"),
                    Time.iso8601("2025-01-01T00:00:00Z")..Time.iso8601("2025-12-31T23:59:59.999999999Z")
                  ]
                ],
                yielded_args
              )
            end
          end
        end
      end

      describe "when past_time is less than mininum" do
        it "also falls back to a mininum past time" do
          around_loop_through do
            yielded_args = []

            described_class.loop_through(
              "year",
              Time.iso8601("2001-08-31T21:00:00-03"),
              Time.iso8601("2025-08-31T21:00:00-03")
            ) do |*args|
              yielded_args << args
            end

            assert_equal(
              [
                [
                  Date.iso8601("2024-12-31"),
                  Time.iso8601("2024-01-01T00:00:00Z")..Time.iso8601("2024-12-31T23:59:59.999999999Z")
                ],
                [
                  Date.iso8601("2025-12-31"),
                  Time.iso8601("2025-01-01T00:00:00Z")..Time.iso8601("2025-12-31T23:59:59.999999999Z")
                ]
              ],
              yielded_args
            )
          end
        end
      end

      describe "when current_time is nil" do
        it "falls back to application past_time" do
          around_loop_through do
            yielded_args = []

            travel_to(Time.iso8601("2025-08-31T21:00:00-03")) do
              described_class.loop_through(
                "year",
                Time.iso8601("2024-08-31T21:00:00-03"),
                nil
              ) do |*args|
                yielded_args << args
              end
            end

            assert_equal(
              [
                [
                  Date.iso8601("2024-12-31"),
                  Time.iso8601("2024-01-01T00:00:00Z")..Time.iso8601("2024-12-31T23:59:59.999999999Z")
                ],
              ],
              yielded_args
            )
          end
        end
      end
    end
  end
end
