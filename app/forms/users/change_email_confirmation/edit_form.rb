# frozen_string_literal: true

module Users
  module ChangeEmailConfirmation
    class EditForm < ApplicationForm
      attribute :token, :string
      attribute :auto_click, :boolean

      validates :token, presence: true

      def method
        :put
      end

      def url
        users_change_email_confirmation_path
      end
    end
  end
end
