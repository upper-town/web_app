# frozen_string_literal: true

module Users
  class EmailConfirmation < ApplicationForm
    attribute :email, :string

    validates :email, presence: true
  end
end
