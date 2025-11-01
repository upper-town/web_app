# frozen_string_literal: true

class ServerBannerImagePolicy
  include Auth::ManageAdminSession
  include Auth::ManageSession

  attr_reader :server, :request

  def initialize(server, request)
    @server = server
    @request = request
  end

  def allowed?
    if current_admin_user
      server.banner_image.present?
    else
      server.banner_image_approved?
    end
  end
end
