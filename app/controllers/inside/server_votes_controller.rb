module Inside
  class ServerVotesController < BaseController
    def index
      @pagination_cursor = PaginationCursor.new(
        current_account.server_votes,
        request,
        cursor_column: :created_at,
        cursor_type: :datetime
      )
      @server_votes = @pagination_cursor.results
    end
  end
end
