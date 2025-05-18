require 'rails_helper'

RSpec.describe ServerStat do
  describe 'associations' do
    it 'belongs to server' do
      server_stat = create(:server_stat)

      expect(server_stat.server).to be_present
    end

    it 'belongs to game' do
      server_stat = create(:server_stat)

      expect(server_stat.game).to be_present
    end
  end

  describe 'validations' do
    it 'validates period' do
      server_stat = build(:server_stat, period: ' ')
      server_stat.validate

      expect(server_stat.errors.of_kind?(:period, :blank)).to be(true)

      server_stat = build(:server_stat, period: 'something_else')
      server_stat.validate

      expect(server_stat.errors.of_kind?(:period, :inclusion)).to be(true)

      server_stat = build(:server_stat, period: Periods::PERIODS.sample)
      server_stat.validate

      expect(server_stat.errors.key?(:period)).to be(false)
    end

    it 'validates country_code' do
      server_stat = build(:server_stat, country_code: ' ')
      server_stat.validate

      expect(server_stat.errors.of_kind?(:country_code, :blank)).to be(true)

      server_stat = build(:server_stat, country_code: 'something_else')
      server_stat.validate

      expect(server_stat.errors.of_kind?(:country_code, :inclusion)).to be(true)

      server_stat = build(:server_stat, country_code: described_class::COUNTRY_CODES.sample)
      server_stat.validate

      expect(server_stat.errors.key?(:country_code)).to be(false)
    end
  end
end
