# frozen_string_literal: true

module TokenGenerator
  module AdminSession
    SECRET = Rails.application.key_generator.generate_key(ENV.fetch("TOKEN_ADMIN_SESSION_SALT"))

    extend self

    def generate
      TokenGenerator.generate(48, SECRET)
    end

    def digest(token)
      TokenGenerator.digest(token, SECRET)
    end
  end
end
