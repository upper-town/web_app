# frozen_string_literal: true

module Users
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
        users_sessions_path
      end
    end
  end
end
