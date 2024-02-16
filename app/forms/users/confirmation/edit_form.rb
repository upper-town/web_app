# frozen_string_literal: true

module Users
  module Confirmation
    class EditForm < ApplicationForm
      attribute :token, :string
      attribute :auto_click, :boolean

      validates :token, presence: true

      def method
        :put
      end

      def url
        users_confirmation_path
      end
    end
  end
end
