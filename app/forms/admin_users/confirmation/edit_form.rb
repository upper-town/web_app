# frozen_string_literal: true

module AdminUsers
  module Confirmation
    class EditForm < ApplicationForm
      attribute :token, :string
      attribute :auto_click, :boolean

      validates :token, presence: true

      def method
        :put
      end

      def url
        admin_users_confirmation_path
      end
    end
  end
end
