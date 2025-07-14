# frozen_string_literal: true

module Seeds
  class CreateServers
    include Callable

    attr_reader :game_ids

    def initialize(game_ids)
      @game_ids = game_ids
    end

    def call
      return unless Rails.env.development?

      server_ids = []

      game_ids.map do |game_id|
        server_hashes = 1.upto(10).map { |n| build_attributes_for_server(game_id, n, "US") }
        result = Server.insert_all(server_hashes)
        server_ids.concat(result.rows.flatten)

        server_hashes = 1.upto(5).map { |n| build_attributes_for_server(game_id, n, "BR") }
        result = Server.insert_all(server_hashes)
        server_ids.concat(result.rows.flatten)
      end

      server_ids
    end

    private

    def build_attributes_for_server(game_id, n, country_code)
      name = "Server-#{n}"
      site_url = "https://server-#{n}.company.com/"
      description = "Zzz Zzz Zzz"
      info = [
        "Aaa Bbb Ccc",
        "Aaa Bbb Ccc",
        "Aaa Bbb Ccc"
      ].join("\n\n").truncate(1_000)

      {
        game_id:,
        name:,
        country_code:,
        site_url:,
        description:,
        info:
      }
    end
  end
end
