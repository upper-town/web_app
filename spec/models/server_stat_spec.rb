# frozen_string_literal: true

# == Schema Information
#
# Table name: server_stats
#
#  id                             :bigint           not null, primary key
#  country_code                   :string           not null
#  period                         :string           not null
#  ranking_number                 :bigint
#  ranking_number_consolidated_at :datetime
#  reference_date                 :date             not null
#  vote_count                     :bigint           default(0), not null
#  vote_count_consolidated_at     :datetime
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  game_id                        :bigint           not null
#  server_id                      :bigint           not null
#
# Indexes
#
#  index_server_stats_on_period_reference_app_country_server  (period,reference_date,game_id,country_code,server_id) UNIQUE
#  index_server_stats_on_server_id                            (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (server_id => servers.id)
#
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
