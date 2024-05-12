# frozen_string_literal: true

class ServerBannerImagesController < ActionController::API
  before_action :ensure_app_host_referer

  def show
    server_banner_image = ServerBannerImage.new(id: id_from_params)

    if server_banner_image.read_from_cache
      render_image(server_banner_image)
    else
      server_banner_image.reload

      if server_banner_image.approved?
        server_banner_image.write_to_cache
        render_image(server_banner_image)
      elsif allowed?(server_banner_image)
        render_image(server_banner_image)
      else
        head(:not_found)
      end
    end
  rescue ActiveRecord::RecordNotFound
    head(:not_found)
  end

  private

  def id_from_params
    @id_from_params ||= params.require(:id)
  end

  def allowed?(server_banner_image)
    ServerBannerImagePolicy.new(server_banner_image, request).allowed?
  end

  def render_image(server_banner_image)
    response.set_header('Cache-Control', "max-age=#{ServerBannerImage::CACHE_EXPIRES_IN}, private")
    response.set_header('ETag', "\"#{server_banner_image.checksum}\"")
    response.set_header('Content-Type', server_banner_image.content_type)
    response.set_header('Content-Disposition', 'inline')

    render(body: server_banner_image.blob)
  end

  def ensure_app_host_referer
    unless RequestHelper.new(request).app_host_referer?
      head(:not_found)
    end
  end
end
