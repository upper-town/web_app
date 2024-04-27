# frozen_string_literal: true

module AdminUsers
  module EmailConfirmation
    class NewForm < ApplicationForm
      attribute :email, :string

      validates :email, presence: true

      def method
        :post
      end

      def url
        admin_users_email_confirmation_path
      end
    end
  end
end
