# frozen_string_literal: true

require "test_helper"

class GameTest < ActiveSupport::TestCase
  let(:described_class) { Game }

  describe "associations" do
    it "has many servers" do
      game = create_game
      server1 = create_server(game:)
      server2 = create_server(game:)

      assert_equal(
        [server1, server2].sort,
        game.servers.sort
      )
      game.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { server1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { server2.reload }
    end

    it "has many server_votes" do
      game = create_game
      server_vote1 = create_server_vote(game:)
      server_vote2 = create_server_vote(game:)

      assert_equal(
        [server_vote1, server_vote2].sort,
        game.server_votes.sort
      )
      game.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { server_vote1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { server_vote2.reload }
    end

    it "has many server_stats" do
      game = create_game
      server_stat1 = create_server_stat(game:)
      server_stat2 = create_server_stat(game:)

      assert_equal(
        [server_stat1, server_stat2].sort,
        game.server_stats.sort
      )
      game.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { server_stat1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { server_stat2.reload }
    end
  end

  describe "normalizations" do
    it "normalizes name" do
      game = create_game(name: "\n\t Game  Name \n")

      assert_equal("Game Name", game.name)
    end

    it "normalizes description" do
      game = create_game(description: "\n\t Game  description \n")

      assert_equal("Game description", game.description)
    end

    it "normalizes info" do
      game = create_game(info: "\n\t Game  info  \n")

      assert_equal("Game  info", game.info)
    end
  end

  describe "validations" do
    it "validates name" do
      game = build_game(name: " ")
      game.validate
      assert(game.errors.of_kind?(:name, :blank))

      game = build_game(name: "a" * 2)
      game.validate
      assert(game.errors.of_kind?(:name, :too_short))

      game = build_game(name: "a" * 256)
      game.validate
      assert(game.errors.of_kind?(:name, :too_long))

      game = build_game(name: "a" * 255)
      game.validate
      assert_not(game.errors.key?(:name))
    end

    it "validates description" do
      game = build_game(description: " ")
      game.validate
      assert_not(game.errors.of_kind?(:description, :blank))

      game = build_game(description: "a" * 1_001)
      game.validate
      assert(game.errors.of_kind?(:description, :too_long))

      game = build_game(description: "a" * 1_000)
      game.validate
      assert_not(game.errors.key?(:description))
    end

    it "validates info" do
      game = build_game(info: " ")
      game.validate
      assert_not(game.errors.of_kind?(:info, :blank))

      game = build_game(info: "a" * 1_001)
      game.validate
      assert(game.errors.of_kind?(:info, :too_long))

      game = build_game(info: "a" * 1_000)
      game.validate
      assert_not(game.errors.key?(:info))
    end

    it "validates site_url" do
      game = build_game(site_url: " ")
      game.validate
      assert_not(game.errors.of_kind?(:site_url, :blank))

      game = build_game(site_url: "a" * 2)
      game.validate
      assert(game.errors.of_kind?(:site_url, :too_short))

      game = build_game(site_url: "a" * 256)
      game.validate
      assert(game.errors.of_kind?(:site_url, :too_long))

      game = build_game(site_url: "abc://game")
      game.validate
      assert(game.errors.of_kind?(:site_url, :format_is_not_valid))

      game = build_game(site_url: "https://game.company.com")
      game.validate
      assert_not(game.errors.key?(:site_url))
    end
  end
end
