# frozen_string_literal: true

module Admin
  class Constraint
    include Auth::AdminManageSession

    attr_accessor :request

    def matches?(request)
      @request = request

      signed_in_admin_user?
    end
  end
end
