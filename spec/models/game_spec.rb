# frozen_string_literal: true

# == Schema Information
#
# Table name: games
#
#  id          :bigint           not null, primary key
#  description :string           default(""), not null
#  info        :text             default(""), not null
#  name        :string           not null
#  site_url    :string           default(""), not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_games_on_name  (name) UNIQUE
#  index_games_on_slug  (slug) UNIQUE
#
require 'rails_helper'

RSpec.describe Game do
  describe 'associations' do
    it 'has many servers' do
      game = create(:game)
      server = create(:server, game: game)

      expect(game.servers).to include(server)
      game.destroy!
      expect { server.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many server_votes' do
      game = create(:game)
      server_vote = create(:server_vote, game: game)

      expect(game.server_votes).to include(server_vote)
      game.destroy!
      expect { server_vote.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many server_stats' do
      game = create(:game)
      server_stat = create(:server_stat, game: game)

      expect(game.server_stats).to include(server_stat)
      game.destroy!
      expect { server_stat.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
