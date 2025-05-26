# frozen_string_literal: true

module CodeGenerator
  module Admin
    SECRET = Rails.application.key_generator.generate_key(ENV.fetch("CODE_ADMIN_SALT"))

    extend self

    def generate
      CodeGenerator.generate(8, SECRET)
    end

    def digest(code)
      CodeGenerator.digest(code, SECRET)
    end
  end
end
