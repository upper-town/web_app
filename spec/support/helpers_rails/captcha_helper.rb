module CaptchaHelper
  def check_captcha
    within('.h-captcha') do
      within_frame do
        find_by_id('checkbox').click
      end
    end
  end
end

RSpec.configure do |config|
  config.include CaptchaHelper, type: :system
end
