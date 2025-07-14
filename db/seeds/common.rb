# frozen_string_literal: true

module Seeds
  module Common
    extend self

    def encrypt_password(unencrypted_password)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

      BCrypt::Password.create(unencrypted_password, cost:)
    end
  end
end
