# frozen_string_literal: true

module Users
  module Confirmation
    class NewForm < ApplicationForm
      attribute :email, :string

      validates :email, presence: true

      def method
        :post
      end

      def url
        users_confirmation_path
      end
    end
  end
end
