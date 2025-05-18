# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("NOREPLY_EMAIL")
  layout "mailer"
end
