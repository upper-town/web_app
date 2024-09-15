# frozen_string_literal: true

module Inside
  class ServerVotesController < BaseController
    def index
      @pagination_cursor = PaginationCursor.new(
        current_account.server_votes,
        request,
        cursor_column: :uuid
      )
      @server_votes = @pagination_cursor.results
    end
  end
end
