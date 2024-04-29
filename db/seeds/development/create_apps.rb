# frozen_string_literal: true

module Seeds
  module Development
    class CreateApps
      def call
        return unless Rails.env.development?

        result = App.insert_all(app_hashes)

        result.rows.flatten # app_ids
      end

      private

      def app_hashes
        [
          {
            slug:        'minecraft',
            name:        'Minecraft',
            type:        App::GAME,
            site_url:    'https://www.minecraft.net/',
            description: '',
            info:        '',
          },
          {
            slug:        'perfect-world-international',
            name:        'Perfect World International (PWI)',
            type:        App::GAME,
            site_url:    'https://www.arcgames.com/en/games/pwi',
            description: '',
            info:        '',
          }
        ]
      end
    end
  end
end
