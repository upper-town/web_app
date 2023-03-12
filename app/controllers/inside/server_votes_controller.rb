# frozen_string_literal: true

module Inside
  class ServerVotesController < BaseController
    def index
      @server_votes = current_user_account.server_votes
    end
  end
end
