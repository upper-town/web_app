# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
module Seeds
  module Development
    class CreateServers
      def initialize(app_ids)
        @app_ids = app_ids
      end

      def call
        return unless Rails.env.development?

        server_ids = []

        @app_ids.map do |app_id|
          server_hashes = 1.upto(10).map { |n| build_attributes_for_server(app_id, n) }
          result = Server.insert_all(server_hashes)

          server_ids.concat(result.rows.flatten)
        end

        server_ids
      end

      private

      def build_attributes_for_server(app_id, n)
        uuid = SecureRandom.uuid
        name = "#{Faker::Lorem.words(number: 3).join(' ').titleize}-#{n}"
        country_code = Seeds::Common.generate_country_code
        site_url = "https://nice-server-#{n}.example.com/"
        banner_image_url = Faker::Avatar.image(
          slug: SecureRandom.uuid,
          size: '750x150',
          bgset: ['bg1', 'bg2'].sample
        )
        description = Faker::Lorem.sentence(word_count: 30)
        info = [
          Faker::Lorem.paragraphs(number: 10).join(' '),
          Faker::Lorem.paragraphs(number: 15).join(' '),
          Faker::Lorem.paragraphs(number: 10).join(' '),
        ].join("\n\n")
        verified_status = Server::PENDING

        {
          app_id:           app_id,
          uuid:             uuid,
          name:             name,
          country_code:     country_code,
          site_url:         site_url,
          banner_image_url: banner_image_url,
          description:      description,
          info:             info,
          verified_status:  verified_status,
        }
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
