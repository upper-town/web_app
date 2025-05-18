# frozen_string_literal: true

require "test_helper"

class GameSelectOptionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { GameSelectOptionsQuery }

  describe "#call" do
    describe "when only_in_use is false" do
      it "returns options with label and value for all games" do
        game1 = create_game(name: "Ccc")
        create_server(game: game1)
        create_server(game: game1)
        game2 = create_game(name: "Aaa")
        game3 = create_game(name: "Bbb")
        create_server(game: game3)

        assert_equal(
          [
            ["Aaa", game2.id],
            ["Bbb", game3.id],
            ["Ccc", game1.id]
          ],
          described_class.new(cache_enabled: false).call
        )
      end
    end

    describe "when only_in_use is true" do
      it "returns options with label and value only for games that have servers" do
        game1 = create_game(name: "Ccc")
        create_server(game: game1)
        create_server(game: game1)
        _game2 = create_game(name: "Aaa")
        game3 = create_game(name: "Bbb")
        create_server(game: game3)

        assert_equal(
          [
            ["Bbb", game3.id],
            ["Ccc", game1.id]
          ],
          described_class.new(only_in_use: true, cache_enabled: false).call
        )
      end
    end

    describe "with cache_enabled" do
      it "caches result" do
        game1 = create_game(name: "Ccc")
        create_server(game: game1)
        create_server(game: game1)
        game2 = create_game(name: "Aaa")
        game3 = create_game(name: "Bbb")
        create_server(game: game3)

        called = 0
        Rails.cache.stub(:fetch, ->(key, options, &block) do
          called += 1
          assert_equal("game_select_options_query:only_in_use", key)
          assert_equal({ expires_in: 5.minutes }, options)
          assert_equal(
            [
              ["Bbb", game3.id],
              ["Ccc", game1.id]
            ],
            block.call
          )
        end) do
          described_class.new(only_in_use: true,  cache_enabled: true).call
        end
        assert_equal(1, called)

        called = 0
        Rails.cache.stub(:fetch, ->(key, options, &block) do
          called += 1
          assert_equal("game_select_options_query", key)
          assert_equal({ expires_in: 5.minutes }, options)
          assert_equal(
            [
              ["Aaa", game2.id],
              ["Bbb", game3.id],
              ["Ccc", game1.id]
            ],
            block.call
          )
        end) do
          described_class.new(only_in_use: false, cache_enabled: true).call
        end
        assert_equal(1, called)
      end
    end
  end
end
