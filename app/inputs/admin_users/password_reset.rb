module AdminUsers
  class PasswordReset < ApplicationModel
    attribute :email, :string, default: nil

    validates :email, presence: true, length: { minimum: 3, maximum: 255 }

    def email=(value)
      super(NormalizeEmail.call(value))
    end
  end
end
