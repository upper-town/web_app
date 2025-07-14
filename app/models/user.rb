# frozen_string_literal: true

class User < ApplicationRecord
  include FeatureFlagId
  include HasTokens
  include HasCodes
  include HasEmailConfirmation
  include HasChangeEmailConfirmation
  include HasPassword
  include HasLock

  has_one :account, class_name: "Account", dependent: :destroy

  has_many :sessions, class_name: "Session", dependent: :destroy
  has_many :tokens,   class_name: "Token",   dependent: :destroy
  has_many :codes,    class_name: "Code",    dependent: :destroy
end
