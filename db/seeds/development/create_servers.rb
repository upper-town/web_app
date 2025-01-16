# frozen_string_literal: true

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
        name = "#{Faker::Lorem.words(number: 3).join(' ').titleize}-#{n}"
        site_url = "https://nice-server-#{n}.company.com/"
        # banner_image_url = Faker::Avatar.image(
        #   size: '750x150',
        #   bgset: ['bg1', 'bg2'].sample
        # )
        description = Faker::Lorem.sentence(word_count: 30)
        info = [
          Faker::Lorem.paragraphs(number: 10).join(' '),
          Faker::Lorem.paragraphs(number: 15).join(' '),
          Faker::Lorem.paragraphs(number: 10).join(' '),
        ].join("\n\n").truncate(1_000)

        {
          game_id:          game_id,
          name:             name,
          country_code:     country_code,
          site_url:         site_url,
          # banner_image_url: banner_image_url,
          description:      description,
          info:             info,
        }
      end
    end
  end
end
