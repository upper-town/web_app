require 'rails_helper'

RSpec.describe PeriodSelectOptionsQuery do
  describe '#call' do
    it 'returns list of period options with label and value' do
      expect(described_class.new.call).to eq([
        [ 'Year',  'year' ],
        [ 'Month', 'month' ],
        [ 'Week',  'week' ]
      ])
    end
  end
end
