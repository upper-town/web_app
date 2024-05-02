# frozen_string_literal: true

module AdminUsers
  class EmailConfirmation < ApplicationModel
    attribute :email, :string

    validates :email, presence: true
  end
end
