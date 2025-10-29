# frozen_string_literal: true

ActiveSupport::Notifications.subscribe "enqueue_retry.active_job" do |event|
  SolidQueue.logger.error(
    "#{event.payload[:job].class}: " \
    "#{event.payload[:error].class}: " \
    "#{event.payload[:error].message}:" \
    "#{event.payload[:job].arguments.inspect}"
  )
end
