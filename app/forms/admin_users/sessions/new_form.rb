# frozen_string_literal: true

module AdminUsers
  module Sessions
    class NewForm < ApplicationForm
      attribute :email, :string
      attribute :password, :string
      attribute :remember_me, :boolean

      validates(
        :email,
        :password,
        presence: true
      )

      def email=(value)
        super(EmailNormalizer.new(value).call)
      end

      def method
        :post
      end

      def url
        admin_users_sessions_path
      end
    end
  end
end
