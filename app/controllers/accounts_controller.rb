class AccountsController < ApplicationController
  def show
    @account_server_votes_total = account_server_votes_total_query
  end

  private

  def account_server_votes_total_query
    Rails.cache.fetch(
      "account_server_votes_total:#{current_user.id}",
      expires_in: 30.seconds
    ) do
      ServerVote.where(account: current_user).count
    end
  end
end
