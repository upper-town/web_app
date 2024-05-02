# frozen_string_literal: true

module Servers
  class Create
    attr_reader :server, :server_banner_image_uploaded_file, :user_account

    def initialize(server, server_banner_image_uploaded_file, user_account)
      @server = server
      @server_banner_image_uploaded_file = server_banner_image_uploaded_file
      @user_account = user_account
    end

    def call
      if server.invalid?
        return Result.failure(server.errors)
      end

      if server_banner_image_uploaded_file.invalid?
        return Result.failure(server_banner_image_uploaded_file.errors)
      end

      ApplicationRecord.transaction do
        server.save!

        if server_banner_image_uploaded_file.present?
          server.create_banner_image!(
            content_type: server_banner_image_uploaded_file.content_type,
            blob: server_banner_image_uploaded_file.blob,
            byte_size: server_banner_image_uploaded_file.byte_size,
            checksum: server_banner_image_uploaded_file.checksum,
            approved_at: nil
          )
        end

        server.user_accounts << user_account
      end

      Result.success(server: server)
    end
  end
end
