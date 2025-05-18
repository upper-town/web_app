module Users
  class ChangeEmailConfirmation < ApplicationModel
    attribute :email, :string, default: nil
    attribute :change_email, :string, default: nil
    attribute :password, :string, default: nil

    validates :email, presence: true, length: { minimum: 3, maximum: 255 }
    validates :change_email, presence: true, length: { minimum: 3, maximum: 255 }
    validates :password, presence: true, length: { maximum: 255 }

    def email=(value)
      super(NormalizeEmail.call(value))
    end

    def change_email=(value)
      super(NormalizeEmail.call(value))
    end
  end
end
