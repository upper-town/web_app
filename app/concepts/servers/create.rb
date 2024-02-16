# frozen_string_literal: true

module Servers
  class Create
    def initialize(attributes, user_account)
      @attributes = attributes
      @user_account = user_account
    end

    def call
      server = build_server
      return Result.failure(server.errors) if server.invalid?

      ApplicationRecord.transaction do
        server.save!
        ServerUserAccount.create!(server: server, user_account: @user_account)
      end

      Result.success(server: server)
    end

    private

    def build_server
      Server.new(
        uuid:         SecureRandom.uuid,
        app:          App.find_by_suuid(@attributes['app_id']),
        country_code: @attributes['country_code'],
        name:         @attributes['name'],
        site_url:     @attributes['site_url'],
      )
    end
  end
end
