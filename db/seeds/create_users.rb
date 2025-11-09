# frozen_string_literal: true

module Seeds
  class CreateUsers
    include Callable

    def call
      User.insert_all(demo_user_hashes)

      result = User.insert_all(user_hashes)
      result.rows.flatten # user_idss
    end

    private

    def demo_user_hashes
      [
        {
          id: 101,
          email: "demo.user1@#{AppUtil.webapp_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current,
        },
        {
          id: 202,
          email: "demo.user2@#{AppUtil.webapp_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current,
        }
      ]
    end

    def user_hashes
      1.upto(10).map do |n|
        {
          email: "user#{n}@#{AppUtil.webapp_host}",
          password_digest: Seeds::Common.encrypt_password("testpass"),
          email_confirmed_at: Time.current
        }
      end
    end
  end
end
