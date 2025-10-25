# frozen_string_literal: true

module Servers
  class Create
    include Callable

    class Result < ApplicationResult
      attribute :server
    end

    attr_reader :server, :server_banner_image, :account

    def initialize(server, account, server_banner_image = nil)
      @server = server
      @account = account
      @server_banner_image = server_banner_image
    end

    def call
      if server.invalid?
        return Result.failure(server.errors)
      end

      if server_banner_image&.invalid?
        return Result.failure(server_banner_image.errors)
      end

      ApplicationRecord.transaction do
        server.save!

        if server_banner_image.present?
          server.banner_image.attach(
            io: server_banner_image.uploaded_file,
            filename: server_banner_image.filename
          )
          server.unapprove_banner_image!
        end

        server.accounts << account
      end

      Result.success(server:)
    end
  end
end
