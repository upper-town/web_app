# frozen_string_literal: true

module Admin
  class JobsConstraint
    include Auth::ManageAdminSession

    attr_accessor :request

    def matches?(request)
      @request = request

      Admin::AccessPolicy
        .new(current_admin_account, AdminPermission::JOBS_ACCESS)
        .allowed?
    end
  end
end
