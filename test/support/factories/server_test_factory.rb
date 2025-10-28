# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:server, Server,
  game: -> { build_game },
  name: -> { "Server #{SecureRandom.base58}" },
  country_code: -> { "US" },
  site_url: -> { "https://server-#{SecureRandom.base58}.upper.town/" }
)
