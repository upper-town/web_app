module Seeds
  module Common
    def self.encrypt_password(unencrypted_password)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

      BCrypt::Password.create(unencrypted_password, cost: cost)
    end
  end
end
