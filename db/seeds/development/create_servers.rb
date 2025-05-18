module Seeds
  module Development
    class CreateServers
      attr_reader :game_ids

      def initialize(game_ids)
        @game_ids = game_ids
      end

      def call
        return unless Rails.env.development?

        server_ids = []

        game_ids.map do |game_id|
          server_hashes = 1.upto(10).map { |n| build_attributes_for_server(game_id, n, 'US') }
          result = Server.insert_all(server_hashes)

          server_ids.concat(result.rows.flatten)

          server_hashes = 1.upto(5).map { |n| build_attributes_for_server(game_id, n, 'BR') }
          result = Server.insert_all(server_hashes)

          server_ids.concat(result.rows.flatten)
        end

        server_ids
      end

      private

      def build_attributes_for_server(game_id, n, country_code)
        name = "Server-#{n}"
        site_url = "https://nice-server-#{n}.company.com/"
        # TODO: banner_image_url
        description = 'Zzz Zzz Zzz'
        info = [
          'Aaa Bbb Ccc',
          'Aaa Bbb Ccc',
          'Aaa Bbb Ccc'
        ].join("\n\n").truncate(1_000)

        {
          game_id:          game_id,
          name:             name,
          country_code:     country_code,
          site_url:         site_url,
          # banner_image_url: banner_image_url,
          description:      description,
          info:             info
        }
      end
    end
  end
end
