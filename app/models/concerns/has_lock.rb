# frozen_string_literal: true

module HasLock
  extend ActiveSupport::Concern

  def locked?
    locked_at.present?
  end

  def unlocked?
    !locked?
  end

  def lock_access!(reason, comment = nil)
    update!(
      locked_reason:  reason,
      locked_comment: comment,
      locked_at:      Time.current
    )
  end

  def unlock_access!
    update!(
      locked_reason:  nil,
      locked_comment: nil,
      locked_at:      nil,
    )
  end
end
