# frozen_string_literal: true

class DeleteExpiredTokensJob < ApplicationJob
  limits_concurrency key: ->(*) { "0" }

  def perform
    Token.expired.delete_all
    AdminToken.expired.delete_all
  end
end
