# frozen_string_literal: true

module Seeds
  class CreateUsers
    prepend Callable

    def call
      result = User.insert_all(user_hashes)
      result.rows.flatten # user_idss
    end

    private

    def user_hashes
      1.upto(10).map do |n|
        {
          email: "user#{n}@#{AppUtil.web_app_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current
        }
      end
    end
  end
end
