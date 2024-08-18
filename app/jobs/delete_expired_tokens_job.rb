# frozen_string_literal: true

class DeleteExpiredTokensJob
  include Sidekiq::Job

  sidekiq_options(lock: :while_executing)

  def perform
    Token.expired.delete_all
    AdminToken.expired.delete_all
  end
end
