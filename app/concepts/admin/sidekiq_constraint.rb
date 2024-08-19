# frozen_string_literal: true

module Admin
  class SidekiqConstraint
    include Auth::ManageAdminSession

    attr_accessor :request

    def matches?(request)
      @request = request

      Admin::AccessPolicy.new(current_admin_account, 'access_sidekiq').allowed?
    end
  end
end
