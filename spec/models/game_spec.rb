require 'rails_helper'

RSpec.describe Game do
  describe 'associations' do
    it 'has many servers' do
      game = create(:game)
      server1 = create(:server, game: game)
      server2 = create(:server, game: game)

      expect(game.servers).to contain_exactly(server1, server2)
      game.destroy!
      expect { server1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many server_votes' do
      game = create(:game)
      server_vote1 = create(:server_vote, game: game)
      server_vote2 = create(:server_vote, game: game)

      expect(game.server_votes).to contain_exactly(server_vote1, server_vote2)
      game.destroy!
      expect { server_vote1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server_vote2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many server_stats' do
      game = create(:game)
      server_stat1 = create(:server_stat, game: game)
      server_stat2 = create(:server_stat, game: game)

      expect(game.server_stats).to contain_exactly(server_stat1, server_stat2)
      game.destroy!
      expect { server_stat1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { server_stat2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'normalizations' do
    it 'normalizes name' do
      game = create(:game, name: "\n\t Game  Name \n")

      expect(game.name).to eq('Game Name')
    end

    it 'normalizes description' do
      game = create(:game, description: "\n\t Game  description \n")

      expect(game.description).to eq('Game description')
    end

    it 'normalizes info' do
      game = create(:game, info: "\n\t Game  info  \n")

      expect(game.info).to eq('Game  info')
    end
  end

  describe 'validations' do
    it 'validates name' do
      game = build(:game, name: ' ')
      game.validate
      expect(game.errors.of_kind?(:name, :blank)).to be(true)

      game = build(:game, name: 'a' * 2)
      game.validate
      expect(game.errors.of_kind?(:name, :too_short)).to be(true)

      game = build(:game, name: 'a' * 256)
      game.validate
      expect(game.errors.of_kind?(:name, :too_long)).to be(true)

      game = build(:game, name: 'a' * 255)
      game.validate
      expect(game.errors.key?(:name)).to be(false)
    end

    it 'validates description' do
      game = build(:game, description: ' ')
      game.validate
      expect(game.errors.of_kind?(:description, :blank)).to be(false)

      game = build(:game, description: 'a' * 1_001)
      game.validate
      expect(game.errors.of_kind?(:description, :too_long)).to be(true)

      game = build(:game, description: 'a' * 1_000)
      game.validate
      expect(game.errors.key?(:description)).to be(false)
    end

    it 'validates info' do
      game = build(:game, info: ' ')
      game.validate
      expect(game.errors.of_kind?(:info, :blank)).to be(false)

      game = build(:game, info: 'a' * 1_001)
      game.validate
      expect(game.errors.of_kind?(:info, :too_long)).to be(true)

      game = build(:game, info: 'a' * 1_000)
      game.validate
      expect(game.errors.key?(:info)).to be(false)
    end

    it 'validates site_url' do
      game = build(:game, site_url: ' ')
      game.validate
      expect(game.errors.of_kind?(:site_url, :blank)).to be(false)

      game = build(:game, site_url: 'a' * 2)
      game.validate
      expect(game.errors.of_kind?(:site_url, :too_short)).to be(true)

      game = build(:game, site_url: 'a' * 256)
      game.validate
      expect(game.errors.of_kind?(:site_url, :too_long)).to be(true)

      game = build(:game, site_url: 'abc://game')
      game.validate
      expect(game.errors.of_kind?(:site_url, :format_is_not_valid)).to be(true)

      game = build(:game, site_url: 'https://game.company.com')
      game.validate
      expect(game.errors.key?(:site_url)).to be(false)
    end
  end
end
