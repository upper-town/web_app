# frozen_string_literal: true

class ServerBannerImagePolicy
  include Auth::AdminUserManageSession
  include Auth::UserManageSession

  attr_reader :server_banner_image, :request

  def initialize(server_banner_image, request)
    @server_banner_image = server_banner_image
    @request = request
  end

  def allowed?
    if current_admin_user
      true
    elsif current_user
      ServerUserAccount.exists?(
        server_id: server_banner_image.server_id,
        user_account_id: current_user_account.id
      )
    else
      false
    end
  end
end
