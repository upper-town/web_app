class User < ApplicationRecord
  include FeatureFlagId
  include HasTokens
  include HasEmailConfirmation
  include HasPassword
  include HasLock

  has_one :account, class_name: "Account", dependent: :destroy

  has_many :sessions, class_name: "Session", dependent: :destroy
  has_many :tokens, class_name: "Token", dependent: :destroy
end
