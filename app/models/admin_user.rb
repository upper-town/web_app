# frozen_string_literal: true

class AdminUser < ApplicationRecord
  include FeatureFlagId
  include HasAdminTokens
  include HasEmailConfirmation
  include HasPassword
  include HasLock

  has_one :account, class_name: "AdminAccount", dependent: :destroy

  has_many :sessions, class_name: "AdminSession", dependent: :destroy
  has_many :tokens, class_name: "AdminToken", dependent: :destroy
end
