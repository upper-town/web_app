# frozen_string_literal: true

module Admin
  class Constraint
    include Auth::ManageActiveSession[AdminUser]

    attr_accessor :request

    def matches?(request)
      @request = request

      signed_in?
    end
  end
end
