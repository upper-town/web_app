# frozen_string_literal: true

class ServerBannerImagePolicy
  attr_reader :server_banner_image

  def initialize(server_banner_image)
    @server_banner_image = server_banner_image
  end

  def allowed?
    case Current.auth_model
    when User
      ServerUserAccount.exists?(
        server_id: server_banner_image.server_id,
        user_account_id: Current.auth_model_account.id
      )
    when AdminUser
      true
    else
      false
    end
  end
end
