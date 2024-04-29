# frozen_string_literal: true

module Seeds
  module Development
    class ConsolidateServerRankingNumbers
      attr_reader :app_ids

      def initialize(app_ids)
        @app_ids = app_ids
      end

      def call
        return unless Rails.env.development?

        app_ids.each do |app_id|
          Servers::ConsolidateRankingsJob.new.perform(app_id, 'all')
        end
      end
    end
  end
end
