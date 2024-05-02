# frozen_string_literal: true

module AdminUsers
  class EmailConfirmation < ApplicationModel
    attribute :token, :string
    attribute :auto_click, :boolean

    validates :token, presence: true
  end
end
