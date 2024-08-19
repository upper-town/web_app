# frozen_string_literal: true

module ManageCaptcha
  extend ActiveSupport::Concern

  include JsonCookie

  CAPTCHA_SKIP_NAME = 'captcha_skip'

  included do
    helper_method(
      :captcha_script_tag,
      :captcha_widget_tag,
    )
  end

  def captcha_check(if_success_skip_paths: [], limit: 2)
    perform_captcha_skip || perform_captcha_check(if_success_skip_paths, limit)
  end

  def captcha_script_tag
    return if read_captcha_skip.can_skip?(request.path)

    Captcha.script_tag(request)
  end

  def captcha_widget_tag(...)
    return if read_captcha_skip.can_skip?(request.path)

    Captcha.widget_tag(...)
  end

  private

  def perform_captcha_skip
    captcha_skip = read_captcha_skip

    if captcha_skip.can_skip?(request.path)
      count = captcha_skip.consume
      delete_captcha_skip if count <= 0

      Result.success
    end
  end

  def perform_captcha_check(if_success_skip_paths, limit)
    result = Captcha.call(request)

    if result.success? && if_success_skip_paths.any?
      write_captcha_skip(if_success_skip_paths, limit)
    end

    result
  end

  def read_captcha_skip
    CaptchaSkip.new(read_json_cookie(CAPTCHA_SKIP_NAME))
  end

  def write_captcha_skip(paths, limit)
    token = TokenGenerator.generate(26).first
    captcha_skip = CaptchaSkip.new(token: token, paths: paths)

    Caching.redis.set(captcha_skip.key, limit, ex: 1.hour)

    write_json_cookie(CAPTCHA_SKIP_NAME, captcha_skip)
  end

  def delete_captcha_skip
    delete_json_cookie(CAPTCHA_SKIP_NAME)
  end

  class CaptchaSkip < ApplicationModel
    attribute :token, :string, default: ''
    attribute :paths, array: true, default: []

    validates :token, presence: true
    validates :paths, presence: true

    def key
      "#{CAPTCHA_SKIP_NAME}:#{token}"
    end

    def paths=(value)
      super(Array(value).compact_blank)
    end

    def can_skip?(path)
      return false unless valid?
      return false unless paths.include?(path)

      count = Caching.redis.get(key)
      return false unless count

      count.to_i.positive?
    end

    def consume
      Caching.redis.decr(key)
    end
  end
end
