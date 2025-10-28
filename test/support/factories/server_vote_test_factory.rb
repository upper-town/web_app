# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:server_vote, ServerVote,
  server: -> { build_server },
  game: -> { build_game },
  country_code: -> { "US" }
)
