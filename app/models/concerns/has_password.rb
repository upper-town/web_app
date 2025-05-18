module HasPassword
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false

    validates :password, length: { minimum: 8 }, allow_blank: true
  end

  def reset_password!(password)
    update!(
      password:          password,
      password_reset_at: Time.current
    )
  end
end
