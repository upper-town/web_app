# frozen_string_literal: true

module MailerTestSetup
  def setup
    super

    ActionMailer::Base.deliveries.clear
  end
end
