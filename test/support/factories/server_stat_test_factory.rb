# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:server_stat, ServerStat,
  server: -> { build_server },
  game: -> { build_game },
  period: -> { "year" },
  reference_date: -> { "2024-01-01" }
)
