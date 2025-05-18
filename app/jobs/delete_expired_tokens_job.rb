class DeleteExpiredTokensJob < ApplicationJob
  # TODO: rewrite lock: :while_executing)

  def perform
    Token.expired.delete_all
    AdminToken.expired.delete_all
  end
end
