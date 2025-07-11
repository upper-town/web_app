# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self

    policy.connect_src :self, "https://hcaptcha.com", "https://*.hcaptcha.com"
    policy.font_src    :self, :data
    policy.frame_src   :self, "https://hcaptcha.com", "https://*.hcaptcha.com"
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self, "https://hcaptcha.com", "https://*.hcaptcha.com"
    policy.style_src   :self, "https://hcaptcha.com", "https://*.hcaptcha.com"

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = ["script-src", "style-src"]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
