# frozen_string_literal: true

class ServerBannerImagesController < ApplicationController
  def show
    @server_banner_image = ServerBannerImage.find_by(id: params.require(:id))

    if @server_banner_image.nil?
      head(:not_found)
    elsif @server_banner_image.approved?
      render_image(true)
    else
      allowed? ? render_image(false) : head(:not_found)
    end
  end

  private

  def allowed?
    ServerBannerImagePolicy.new(@server_banner_image, request).allowed?
  end

  def render_image(cache_public)
    if cache_public
      response.set_header('Cache-Control', 'max-age=31536000, public, immutable')
    else
      response.set_header('Cache-Control', 'max-age=600, private, immutable')
    end

    response.set_header('Content-Type', @server_banner_image.content_type)
    response.set_header('ETag', "\"#{@server_banner_image.checksum}\"")

    render(body: @server_banner_image.blob)
  end
end
