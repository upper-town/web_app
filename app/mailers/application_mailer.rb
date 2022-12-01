# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreplay@etherblade.city'
  layout 'mailer'
end
