# frozen_string_literal: true

module Admin
  class SidekiqConstraint
    include Auth::ManageActiveSession[AdminUser]

    attr_accessor :request

    def matches?(request)
      @request = request

      Admin::AccessPolicy.new(current_model, 'access_sidekiq').allowed?
    end
  end
end
