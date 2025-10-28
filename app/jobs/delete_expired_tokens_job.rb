# frozen_string_literal: true

class DeleteExpiredTokensJob < ApplicationJob
  def perform
    Token.expired.delete_all
    AdminToken.expired.delete_all
  end
end
