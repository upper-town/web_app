# frozen_string_literal: true

module Servers
  class Create
    def initialize(form_attributes, user_account)
      @form_attributes = form_attributes
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
        app:          App.find_by_suuid(@form_attributes['app_id']),
        country_code: @form_attributes['country_code'],
        name:         @form_attributes['name'],
        site_url:     @form_attributes['site_url'],
      )
    end
  end
end
