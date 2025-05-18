module HasAdminTokens
  TOKEN_EXPIRATION = 30.minutes

  extend ActiveSupport::Concern

  include HasTokens

  class_methods do
    def token_generator
      TokenGenerator::Admin
    end
  end
end
