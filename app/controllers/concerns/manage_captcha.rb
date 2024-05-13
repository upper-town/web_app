# frozen_string_literal: true

module ManageCaptcha
  MANAGE_CAPTCHA_TOKEN_LENGTH = 24

  extend ActiveSupport::Concern

  include CookieJsonValue

  CAPTCHA_SKIP = 'captcha_skip'

  included do
    helper_method(
      :captcha_script_tag,
      :captcha_widget_tag,
    )
  end

  def captcha_check(if_success_skip_paths: [], limit: 2)
    if can_skip_captcha?
      consume_captcha_skip

      return Result.success
    end

    result = Captcha.call(request)

    if result.success? && if_success_skip_paths.any?
      create_captcha_skip(if_success_skip_paths, limit)
    end

    result
  end

  def captcha_script_tag
    return if can_skip_captcha?

    Captcha.script_tag(request)
  end

  def captcha_widget_tag(...)
    return if can_skip_captcha?

    Captcha.widget_tag(...)
  end

  def can_skip_captcha?
    captcha_skip = parse_captcha_skip
    return false unless captcha_skip.paths.include?(request.path)

    count = Caching.redis.get(captcha_skip.key)
    return false unless count

    count.to_i.positive?
  end

  private

  def create_captcha_skip(paths, limit)
    key = "captcha_skip:#{SecureRandom.base58(MANAGE_CAPTCHA_TOKEN_LENGTH)}"
    Caching.redis.set(key, limit, ex: 1.hour)

    captcha_skip = CaptchaSkip.new(key: key, paths: paths)
    write_cookie_json_value(CAPTCHA_SKIP, captcha_skip)
  end

  def parse_captcha_skip
    attributes = parse_cookie_json_value(CAPTCHA_SKIP)
    CaptchaSkip.new(attributes)
  end

  def consume_captcha_skip
    captcha_skip = parse_captcha_skip
    count = Caching.redis.decr(captcha_skip.key)

    request.cookie_jar.delete(CAPTCHA_SKIP) if count <= 0
  end

  class CaptchaSkip < ApplicationModel
    attribute :key, :string, default: 'captcha_skip'
    attribute :paths, array: true, default: []

    def paths=(value)
      super(Array(value).compact_blank)
    end
  end
end
