# frozen_string_literal: true

module Servers
  class NewForm < ApplicationForm
    MAX_PENDING_SERVER_COUNT = 1

    attr_accessor :user_account

    attribute :app_id,       :string # suuid
    attribute :country_code, :string
    attribute :name,         :string
    attribute :site_url,     :string

    validate :max_pending_server_per_user_account

    def method
      :post
    end

    def url
      inside_servers_path
    end

    private

    def max_pending_server_per_user_account
      count = user_account.servers.where(verified_status: Server::PENDING).count

      if count >= MAX_PENDING_SERVER_COUNT
        errors.add(
          :base,
          "You have many servers pending verification.
           Please verify them first before adding more servers."
        )
      end
    end
  end
end
