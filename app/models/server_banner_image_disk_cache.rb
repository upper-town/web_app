# frozen_string_literal: true

class ServerBannerImageDiskCache
  attr_reader :id, :pathname

  def initialize(id)
    @id = id.to_i
    @pathname = Pathname.new("/tmp/server_banner_images/#{id}")
  end

  def exists?
    pathname.exist?
  end

  def read
    pathname.binread if exists?
  end

  def write(blob)
    pathname.dirname.mkpath
    pathname.binwrite(blob)
  end

  def delete
    pathname.delete if exists?
  end
end
