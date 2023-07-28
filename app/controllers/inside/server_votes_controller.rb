# frozen_string_literal: true

module Inside
  class ServerVotesController < BaseController
    def index
      @pagination_cursor = PaginationCursor.new(
        current_user_account.server_votes,
        request,
        options: { per_page: 50 }
      )
      @server_votes = @pagination_cursor.results

      status = if !@pagination_cursor.start_cursor? && @server_votes.empty?
        :not_found
      else
        :ok
      end

      render(status: status)
    end
  end
end
