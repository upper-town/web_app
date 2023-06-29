# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
module Seeds
  module Development
    class CreateUsers
      PASSWORD = 'testpass'

      def call
        return unless Rails.env.development?

        result = User.insert_all(user_hashes)

        result.rows.flatten # user_ids
      end

      private

      def user_hashes
        1.upto(10).map do |n|
          {
            uuid: SecureRandom.uuid,
            email: "user.#{n}@#{ENV.fetch('HOST')}",
            encrypted_password: Devise::Encryptor.digest(User, PASSWORD),
            confirmed_at: Time.current,
          }
        end
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
