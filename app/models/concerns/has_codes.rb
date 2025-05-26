# frozen_string_literal: true

module HasCodes
  CODE_EXPIRATION = 30.minutes

  extend ActiveSupport::Concern

  class_methods do
    def code_generator
      CodeGenerator
    end

    def find_by_code(purpose, code)
      return if purpose.blank? || code.blank?

      joins(:codes)
        .where(codes: { purpose: purpose, code_digest: code_generator.digest(code) })
        .where("codes.expires_at > ?", Time.current)
        .first
    end
  end

  def generate_code!(purpose, expires_in = nil, data = {})
    expires_in ||= CODE_EXPIRATION

    code, code_digest = self.class.code_generator.generate

    codes.create!(
      purpose: purpose,
      expires_at: expires_in.from_now,
      data: data,
      code_digest: code_digest
    )

    code
  end

  def expire_code!(purpose)
    return if purpose.blank?

    codes.where(purpose: purpose).update_all(expires_at: 2.days.ago)
  end
end
