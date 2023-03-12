# frozen_string_literal: true

module Users
  class InitializeAccount
    def initialize(user)
      @user = user
    end

    def call
      create! unless exists?
    end

    private

    def exists?
      UserAccount.exists?(user: @user)
    end

    def create!
      UserAccount.create!(
        user: @user,
        uuid: SecureRandom.uuid
      )
    end
  end
end
