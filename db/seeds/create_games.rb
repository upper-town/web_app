# frozen_string_literal: true

module Seeds
  class CreateGames
    include Callable

    def call
      Game.insert_all(demo_game_hashes)

      result = Game.insert_all(game_hashes)
      result.rows.flatten # game_ids
    end

    private

    def demo_game_hashes
      [
        {
          id:          100,
          slug:        "demo-game",
          name:        "Demo Game",
          site_url:    "https://example.com/demo-game/",
          description: "",
          info:        ""
        },
      ]
    end

    def game_hashes
      [
        {
          slug:        "minecraft",
          name:        "Minecraft",
          site_url:    "https://www.minecraft.net/",
          description: "",
          info:        ""
        },
        {
          slug:        "perfect-world-international",
          name:        "Perfect World International (PWI)",
          site_url:    "https://www.arcgames.com/en/games/pwi",
          description: "",
          info:        ""
        }
      ]
    end
  end
end
