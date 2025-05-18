# Be sure to restart your server when you modify this file.

# Define an application-wide HTTP permissions policy. For further
# information see: https://developers.google.com/web/updates/2018/06/feature-policy

Rails.application.config.permissions_policy do |policy|
  policy.accelerometer :none
  policy.autoplay      :none
  policy.camera        :none
  policy.fullscreen    :self
  policy.geolocation   :none
  policy.gyroscope     :none
  policy.microphone    :none
  policy.payment       :none
  policy.usb           :none
end
