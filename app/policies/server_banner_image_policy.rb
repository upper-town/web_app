class ServerBannerImagePolicy
  include Auth::ManageAdminSession
  include Auth::ManageSession

  attr_reader :server_banner_image, :request

  def initialize(server_banner_image, request)
    @server_banner_image = server_banner_image
    @request = request
  end

  def allowed?
    if current_admin_user
      true
    elsif current_user
      ServerAccount.exists?(
        server_id: server_banner_image.server_id,
        account_id: current_account.id
      )
    else
      false
    end
  end
end
