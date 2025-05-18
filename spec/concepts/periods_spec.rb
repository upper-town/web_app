require 'rails_helper'

RSpec.describe Periods do
  describe 'min_past_time' do
    it 'parses and returns from env var' do
      EnvVarHelper.with_values('PERIODS_MIN_PAST_TIME' => '2024-01-01T00:00:00Z') do
        min_past_time = described_class.min_past_time

        expect(min_past_time).to eq(Time.iso8601('2024-01-01T00:00:00Z'))
      end
    end
  end

  describe 'reference_date_for' do
    context 'when period is year' do
      it 'returns the end_of_year date in UTC' do
        reference_date = described_class.reference_date_for(
          'year', Time.iso8601('2024-12-31T21:00:00-03')
        )

        expect(reference_date).to eq(Date.iso8601('2025-12-31'))
      end
    end

    context 'when period is month' do
      it 'returns the end_of_month date in UTC' do
        reference_date = described_class.reference_date_for(
          'month', Time.iso8601('2024-08-31T21:00:00-03')
        )

        expect(reference_date).to eq(Date.iso8601('2024-09-30'))
      end
    end

    context 'when period is week' do
      it 'returns the end_of_week date in UTC' do
        reference_date = described_class.reference_date_for(
          'week', Time.iso8601('2024-09-01T21:00:00-03')
        )

        expect(reference_date).to eq(Date.iso8601('2024-09-08'))
      end
    end

    context 'when period is something else' do
      it 'raises an error' do
        expect do
          described_class.reference_date_for('something_else', Time.current)
        end.to raise_error(/Invalid period for Periods.reference_date_for/)
      end
    end
  end

  describe 'reference_range_for' do
    context 'when period is year' do
      it 'returns all_year range in UTC' do
        reference_range = described_class.reference_range_for(
          'year', Time.iso8601('2024-12-31T21:00:00-03')
        )

        expect(reference_range).to eq(
          Time.iso8601('2025-01-01T00:00:00Z')..Time.iso8601('2025-12-31T23:59:59.999999999Z')
        )
      end
    end

    context 'when period is month' do
      it 'returns all_month date in UTC' do
        reference_range = described_class.reference_range_for(
          'month', Time.iso8601('2024-08-31T21:00:00-03')
        )

        expect(reference_range).to eq(
          Time.iso8601('2024-09-01T00:00:00Z')..Time.iso8601('2024-09-30T23:59:59.999999999Z')
        )
      end
    end

    context 'when period is week' do
      it 'returns the end_of_week date in UTC' do
        reference_range = described_class.reference_range_for(
          'week', Time.iso8601('2024-09-01T21:00:00-03')
        )

        expect(reference_range).to eq(
          Time.iso8601('2024-09-02T00:00:00Z')..Time.iso8601('2024-09-08T23:59:59.999999999Z')
        )
      end
    end

    context 'when period is something else' do
      it 'raises an error' do
        expect do
          described_class.reference_range_for('something_else', Time.current)
        end.to raise_error(/Invalid period for Periods.reference_range_for/)
      end
    end
  end

  describe 'next_time_for' do
    context 'when period is year' do
      it 'returns the beginning of next_year time in UTC' do
        reference_date = described_class.next_time_for(
          'year', Time.iso8601('2024-12-31T21:00:00-03')
        )

        expect(reference_date).to eq(Time.iso8601('2026-01-01T00:00:00Z'))
      end
    end

    context 'when period is month' do
      it 'returns the beginning of next_month time in UTC' do
        reference_date = described_class.next_time_for(
          'month', Time.iso8601('2024-08-31T21:00:00-03')
        )

        expect(reference_date).to eq(Time.iso8601('2024-10-01T00:00:00Z'))
      end
    end

    context 'when period is week' do
      it 'returns the beginning of next_week time in UTC' do
        reference_date = described_class.next_time_for(
          'week', Time.iso8601('2024-09-01T21:00:00-03')
        )

        expect(reference_date).to eq(Time.iso8601('2024-09-09T00:00:00Z'))
      end
    end

    context 'when period is something else' do
      it 'raises an error' do
        expect do
          described_class.next_time_for('something_else', Time.current)
        end.to raise_error(/Invalid period for Periods.next_time_for/)
      end
    end
  end

  describe 'loop_through' do
    around do |example|
      EnvVarHelper.with_values('PERIODS_MIN_PAST_TIME' => '2024-01-01T00:00:00Z') do
        example.run
      end
    end

    context 'when past_time is greater than current_time' do
      it 'raises an error' do
        freeze_time do
          expect do |block|
            described_class.loop_through('year', Time.current, 1.second.ago, &block)
          end.to raise_error(/Invalid past_time or current_time for Periods.loop_through/)
        end
      end
    end

    context 'when period is year' do
      it 'yields all reference_date and reference_range years in UTC between past_time and current_time' do
        expect do |block|
          described_class.loop_through(
            'year', Time.iso8601('2024-12-31T21:00:00-03'), Time.iso8601('2027-08-31T21:00:00-03'),
            &block
          )
        end.to yield_successive_args(
          [
            Date.iso8601('2025-12-31'),
            Time.iso8601('2025-01-01T00:00:00Z')..Time.iso8601('2025-12-31T23:59:59.999999999Z')
          ],
          [
            Date.iso8601('2026-12-31'),
            Time.iso8601('2026-01-01T00:00:00Z')..Time.iso8601('2026-12-31T23:59:59.999999999Z')
          ],
          [
            Date.iso8601('2027-12-31'),
            Time.iso8601('2027-01-01T00:00:00Z')..Time.iso8601('2027-12-31T23:59:59.999999999Z')
          ],
        )
      end
    end

    context 'when period is month' do
      it 'yields all reference_date and reference_range months in UTC between past_time and current_time' do
        expect do |block|
          described_class.loop_through(
            'month', Time.iso8601('2024-09-30T21:00:00-03'), Time.iso8601('2024-12-31T21:00:00-03'),
            &block
          )
        end.to yield_successive_args(
          [
            Date.iso8601('2024-10-31'),
            Time.iso8601('2024-10-01T00:00:00Z')..Time.iso8601('2024-10-31T23:59:59.999999999Z')
          ],
          [
            Date.iso8601('2024-11-30'),
            Time.iso8601('2024-11-01T00:00:00Z')..Time.iso8601('2024-11-30T23:59:59.999999999Z')
          ],
          [
            Date.iso8601('2024-12-31'),
            Time.iso8601('2024-12-01T00:00:00Z')..Time.iso8601('2024-12-31T23:59:59.999999999Z')
          ],
          [
            Date.iso8601('2025-01-31'),
            Time.iso8601('2025-01-01T00:00:00Z')..Time.iso8601('2025-01-31T23:59:59.999999999Z')
          ],
        )
      end
    end

    context 'when period is week' do
      it 'yields all reference_date and reference_range weeks in UTC between past_time and current_time' do
        expect do |block|
          described_class.loop_through(
            'week', Time.iso8601('2024-09-01T21:00:00-03'), Time.iso8601('2024-09-22T21:00:00-03'),
            &block
          )
        end.to yield_successive_args(
          [
            Date.iso8601('2024-09-08'),
            Time.iso8601('2024-09-02T00:00:00Z')..Time.iso8601('2024-09-08T23:59:59.999999999Z')
          ],
          [
            Date.iso8601('2024-09-15'),
            Time.iso8601('2024-09-09T00:00:00Z')..Time.iso8601('2024-09-15T23:59:59.999999999Z')
          ],
          [
            Date.iso8601('2024-09-22'),
            Time.iso8601('2024-09-16T00:00:00Z')..Time.iso8601('2024-09-22T23:59:59.999999999Z')
          ],
          [
            Date.iso8601('2024-09-29'),
            Time.iso8601('2024-09-23T00:00:00Z')..Time.iso8601('2024-09-29T23:59:59.999999999Z')
          ],
        )
      end
    end

    describe 'default values and fallbacks' do
      context 'when past_time is nil' do
        it 'falls back to a mininum past time' do
          expect do |block|
            described_class.loop_through(
              'year', nil, Time.iso8601('2025-08-31T21:00:00-03'),
              &block
            )
          end.to yield_successive_args(
            [
              Date.iso8601('2024-12-31'),
              Time.iso8601('2024-01-01T00:00:00Z')..Time.iso8601('2024-12-31T23:59:59.999999999Z')
            ],
            [
              Date.iso8601('2025-12-31'),
              Time.iso8601('2025-01-01T00:00:00Z')..Time.iso8601('2025-12-31T23:59:59.999999999Z')
            ]
          )
        end
      end

      context 'when past_time is less than mininum' do
        it 'also falls back to a mininum past time' do
          expect do |block|
            described_class.loop_through(
              'year', Time.iso8601('2001-08-31T21:00:00-03'), Time.iso8601('2025-08-31T21:00:00-03'),
              &block
            )
          end.to yield_successive_args(
            [
              Date.iso8601('2024-12-31'),
              Time.iso8601('2024-01-01T00:00:00Z')..Time.iso8601('2024-12-31T23:59:59.999999999Z')
            ],
            [
              Date.iso8601('2025-12-31'),
              Time.iso8601('2025-01-01T00:00:00Z')..Time.iso8601('2025-12-31T23:59:59.999999999Z')
            ]
          )
        end
      end

      context 'when current_time is nil' do
        it 'falls back to application Time.current' do
          travel_to(Time.iso8601('2025-08-31T21:00:00-03')) do
            expect do |block|
              described_class.loop_through(
                'year', Time.iso8601('2024-08-31T21:00:00-03'), nil,
                &block
              )
            end.to yield_successive_args(
              [
                Date.iso8601('2024-12-31'),
                Time.iso8601('2024-01-01T00:00:00Z')..Time.iso8601('2024-12-31T23:59:59.999999999Z')
              ],
              [
                Date.iso8601('2025-12-31'),
                Time.iso8601('2025-01-01T00:00:00Z')..Time.iso8601('2025-12-31T23:59:59.999999999Z')
              ]
            )
          end
        end
      end
    end
  end
end
