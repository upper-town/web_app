# frozen_string_literal: true

module Users
  class EmailConfirmationEdit < ApplicationModel
    attribute :token, :string
    attribute :auto_click, :boolean

    validates :token, presence: true
  end
end
