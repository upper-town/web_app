# frozen_string_literal: true

module Servers
  class Create
    attr_reader :server, :user_account

    def initialize(server, user_account)
      @server = server
      @user_account = user_account
    end

    def call
      if server.valid?
        ApplicationRecord.transaction do
          server.save!
          ServerUserAccount.create!(server: server, user_account: user_account)
        end

        Result.success(server: server)
      else
        Result.failure(server.errors, server: server)
      end
    end
  end
end
