# frozen_string_literal: true

module AdminUsers
  class EmailConfirmation < ApplicationForm
    attribute :token, :string
    attribute :auto_click, :boolean

    validates :token, presence: true
  end
end
