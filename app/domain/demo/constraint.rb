# frozen_string_literal: true

module Demo
  class Constraint
    attr_accessor :request

    def matches?(_request)
      Rails.env.development?
    end
  end
end
