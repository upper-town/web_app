# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:server_vote, ServerVote,
  server: -> { build_server },
  game: -> { build_game },
  remote_ip: -> { "1.1.1.1" }
)
