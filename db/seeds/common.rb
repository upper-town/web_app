# frozen_string_literal: true

module Seeds
  module Common
    def self.generate_country_code(reject_values = [])
      reject_values = Array(reject_values)

      [
        'US',
        'BR',
      ].reject do |country_code|
        reject_values.include?(country_code)
      end.sample
    end

    def self.encrypt_password(unencrypted_password)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

      BCrypt::Password.create(unencrypted_password, cost: cost)
    end
  end
end
