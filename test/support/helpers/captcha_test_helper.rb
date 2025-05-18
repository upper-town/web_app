# frozen_string_literal: true

module CaptchaTestHelper
  def check_captcha
    within(".h-captcha") do
      within_frame do
        find_by_id("checkbox").click
      end
    end
  end
end
