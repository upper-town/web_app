# frozen_string_literal: true

module HasPassword
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false, reset_token: false

    validates :password, length: { minimum: 8, maximum: 72 }, allow_nil: true
  end

  def reset_password!(password)
    update!(
      password:,
      password_reset_at: Time.current
    )
  end

  def clear_password!
    update!(
      password: nil,
      password_reset_at: nil
    )
  end
end
