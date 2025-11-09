# frozen_string_literal: true

module Seeds
  class CreateServers
    include Callable

    attr_reader :game_ids

    def initialize(game_ids)
      @game_ids = game_ids
    end

    def call
      result = Server.insert_all(demo_server_hashes)
      ActiveJob.perform_all_later(result.rows.flatten.map { Servers::VerifyJob.new(Server.new(id: it)) })

      server_ids = []

      game_ids.map do |game_id|
        server_hashes = 1.upto(10).map { |n| build_attributes_for_server(game_id, n, "US") }
        result = Server.insert_all(server_hashes)
        server_ids.concat(result.rows.flatten)

        server_hashes = 1.upto(2).map { |n| build_attributes_for_server(game_id, n, "CA") }
        result = Server.insert_all(server_hashes)
        server_ids.concat(result.rows.flatten)

        server_hashes = 1.upto(5).map { |n| build_attributes_for_server(game_id, n, "BR") }
        result = Server.insert_all(server_hashes)
        server_ids.concat(result.rows.flatten)
      end

      server_ids
    end

    private

    def demo_server_hashes
      [
        {
          id:           100,
          game_id:      100,
          name:         "Demo Server",
          country_code: "US",
          site_url:     "http://#{AppUtil.webapp_host}:#{AppUtil.webapp_port}/demo",
          description:  "",
          info:         ""
        }
      ]
    end

    def build_attributes_for_server(game_id, n, country_code)
      name = "Server-#{country_code}-#{n}"
      site_url = "https://server-#{country_code.downcase}-#{n}.company.com/"
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
