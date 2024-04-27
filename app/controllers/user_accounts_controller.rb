# frozen_string_literal: true

class UserAccountsController < ApplicationController
  def show
    @user_account_server_votes_total = user_account_server_votes_total_query
  end

  private

  def user_account_server_votes_total_query
    Rails.cache.fetch(
      "user_account_server_votes_total:#{current_user.id}",
      expires_in: 30.seconds
    ) do
      ServerVote.where(user_account: current_user).count
    end
  end
end
