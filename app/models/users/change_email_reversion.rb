# frozen_string_literal: true

module Users
  class ChangeEmailReversion < ApplicationModel
    attribute :token, :string
    attribute :auto_click, :boolean

    validates :token, presence: true
  end
end
