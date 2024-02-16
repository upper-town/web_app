# frozen_string_literal: true

class DeleteExpiredTokensJob
  include Sidekiq::Job

  sidekiq_options(lock: :while_executing)

  def perform
    UserToken.expired.delete_all
    AdminUserToken.expired.delete_all
  end
end
