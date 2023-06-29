# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
module Seeds
  module Development
    class CreateServerVotes
      def initialize(app_ids, server_ids, user_account_ids)
        @app_ids = app_ids
        @server_ids = server_ids
        @user_account_ids = user_account_ids
      end

      def call
        return unless Rails.env.development?

        server_values.each do |(server_id, server_country_code, server_app_id)|
          server_vote_hashes = []

          (ServerStat::MIN_PAST_TIME.beginning_of_year.to_date..Date.current.end_of_year).each do |day_date|
            country_code = sample_country_code(server_country_code)
            app_id       = sample_app_id(server_app_id)

            SecureRandom.random_number(1..10).times do
              server_vote_hashes << {
                uuid:            SecureRandom.uuid,
                user_account_id: @user_account_ids.sample,
                server_id:       server_id,
                country_code:    country_code,
                app_id:          app_id,
                created_at:      day_date,
                updated_at:      day_date,
              }
            end
          end

          ServerVote.insert_all(server_vote_hashes)
        end
      end

      private

      def server_values
        Server
          .where(id: @server_ids)
          .pluck(:id, :country_code, :app_id)
      end

      # Generate a country_code for the server's vote that's different from the server's country_code 1/5 of the time.
      # The idea is to simulate the server occasionally changed its country_code
      # so it received some votes with different country_codes
      def sample_country_code(server_country_code)
        [
          *Array.new(4) { server_country_code },
          Seeds::Common.generate_country_code(server_country_code)
        ].sample
      end

      # Generate a app_id for the server's vote that's different from the server's app_id 1/5 of the time.
      # The idea is to simulate the server occasionally changed its app_id
      # so it received some votes with different app_ids.
      def sample_app_id(server_app_id)
        [
          *Array.new(4) { server_app_id },
          (@app_ids - [server_app_id]).sample,
        ].sample
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
