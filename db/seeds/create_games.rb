# frozen_string_literal: true

module Seeds
  class CreateGames
    prepend Callable

    def call
      result = Game.insert_all(game_hashes)
      result.rows.flatten # game_ids
    end

    private

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
