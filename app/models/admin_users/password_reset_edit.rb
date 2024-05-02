# frozen_string_literal: true

module AdminUsers
  class PasswordResetEdit < ApplicationModel
    attribute :password, :string
    attribute :token,    :string

    validates(
      :password,
      :token,
      presence: true
    )
  end
end
