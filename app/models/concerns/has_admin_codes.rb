# frozen_string_literal: true

module HasAdminCodes
  CODE_EXPIRATION = 10.minutes

  extend ActiveSupport::Concern

  include HasCodes

  class_methods do
    def code_generator
      CodeGenerator::Admin
    end
  end
end
