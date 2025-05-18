# frozen_string_literal: true

module ActiveRecordFactoryTestHelper
  # Account

  def build_account(**kwargs)
    set_attr(kwargs, :user, build_user)

    Account.new(**kwargs)
  end

  def create_account(...)
    build_account(...).tap { it.save! }
  end

  # AdminAccount

  def build_admin_account(**kwargs)
    set_attr(kwargs, :admin_user, build_admin_user)

    AdminAccount.new(**kwargs)
  end

  def create_admin_account(...)
    build_admin_account(...).tap { it.save! }
  end

  # AdminAccountRole

  def build_admin_account_role(**kwargs)
    set_attr(kwargs, :admin_account, build_admin_account)
    set_attr(kwargs, :admin_role,    build_admin_role)

    AdminAccountRole.new(**kwargs)
  end

  def create_admin_account_role(...)
    build_admin_account_role(...).tap { it.save! }
  end

  # AdminPermission

  def build_admin_permission(**kwargs)
    set_attr(kwargs, :key,         "admin_permission_key_#{random_chars}")
    set_attr(kwargs, :description, "AdminPermission")

    AdminPermission.new(**kwargs)
  end

  def create_admin_permission(...)
    build_admin_permission(...).tap { it.save! }
  end

  # AdminRole

  def build_admin_role(**kwargs)
    set_attr(kwargs, :key,         "admin_role_key_#{random_chars}")
    set_attr(kwargs, :description, "AdminRole")

    AdminRole.new(**kwargs)
  end

  def create_admin_role(...)
    build_admin_role(...).tap { it.save! }
  end

  # AdminRolePermission

  def build_admin_role_permission(**kwargs)
    set_attr(kwargs, :admin_role, build_admin_role)
    set_attr(kwargs, :admin_permission, build_admin_permission)

    AdminRolePermission.new(**kwargs)
  end

  def create_admin_role_permission(...)
    build_admin_role_permission(...).tap { it.save! }
  end

  # AdminSession

  def build_admin_session(**kwargs)
    set_attr(kwargs, :admin_user,      build_admin_user)
    set_attr(kwargs, :token_last_four, "abcd")
    set_attr(kwargs, :token_digest,    Digest::SHA256.hexdigest("admin-token-#{random_chars}-#{kwargs[:token_last_four]}"))
    set_attr(kwargs, :expires_at,      30.days.from_now)
    set_attr(kwargs, :remote_ip,       "255.255.255.255")

    AdminSession.new(**kwargs)
  end

  def create_admin_session(...)
    build_admin_session(...).tap { it.save! }
  end

  # AdminToken

  def build_admin_token(**kwargs)
    set_attr(kwargs, :admin_user,      build_admin_user)
    set_attr(kwargs, :token_last_four, "abcd")
    set_attr(kwargs, :token_digest,    Digest::SHA256.hexdigest("admin-token-#{random_chars}-#{kwargs[:token_last_four]}"))
    set_attr(kwargs, :purpose,         "email_confirmation")
    set_attr(kwargs, :expires_at,      30.days.from_now)

    AdminToken.new(**kwargs)
  end

  def create_admin_token(...)
    build_admin_token(...).tap { it.save! }
  end

  # AdminUser

  def build_admin_user(**kwargs)
    set_attr(kwargs, :email,    "admin.user.#{random_chars}@upper.town")
    set_attr(kwargs, :password, "testpass")

    AdminUser.new(**kwargs)
  end

  def create_admin_user(...)
    build_admin_user(...).tap { it.save! }
  end

  # Dummy

  def build_dummy(**)
    Dummy.new(**)
  end

  def create_dummy(...)
    build_dummy(...).tap { it.save! }
  end

  # FeatureFlag

  def build_feature_flag(**kwargs)
    set_attr(kwargs, :name,  "feature_flag_#{random_chars}")
    set_attr(kwargs, :value, "true")

    FeatureFlag.new(**kwargs)
  end

  def create_feature_flag(...)
    build_feature_flag(...).tap { it.save! }
  end

  # Game

  def build_game(**kwargs)
    set_attr(kwargs, :name, "Game #{random_chars}")
    set_attr(kwargs, :slug, "game-#{random_chars}")

    Game.new(**kwargs)
  end

  def create_game(...)
    build_game(...).tap { it.save! }
  end

  # Server

  def build_server(**kwargs)
    set_attr(kwargs, :game,         build_game)
    set_attr(kwargs, :name,         "Server #{random_chars}")
    set_attr(kwargs, :country_code, "US")
    set_attr(kwargs, :site_url,     "https://server-#{random_chars}.upper.town/")

    Server.new(**kwargs)
  end

  def create_server(...)
    build_server(...).tap { it.save! }
  end

  # ServerAccount

  def build_server_account(**kwargs)
    set_attr(kwargs, :server,  build_server)
    set_attr(kwargs, :account, build_account)

    ServerAccount.new(**kwargs)
  end

  def create_server_account(...)
    build_server_account(...).tap { it.save! }
  end

  # ServerBannerImage

  def build_server_banner_image(**kwargs)
    set_attr(kwargs, :server,       build_server)
    set_attr(kwargs, :content_type, "image/png")
    set_attr(kwargs, :blob,         "")
    set_attr(kwargs, :byte_size,    0)
    set_attr(kwargs, :checksum,     "")

    ServerBannerImage.new(**kwargs)
  end

  def create_server_banner_image(...)
    build_server_banner_image(...).tap { it.save! }
  end

  # ServerStat

  def build_server_stat(**kwargs)
    set_attr(kwargs, :server,         build_server)
    set_attr(kwargs, :game,           build_game)
    set_attr(kwargs, :country_code,   "US")
    set_attr(kwargs, :period,         "year")
    set_attr(kwargs, :reference_date, "2024-01-01")

    ServerStat.new(**kwargs)
  end

  def create_server_stat(...)
    build_server_stat(...).tap { it.save! }
  end

  # ServerVote

  def build_server_vote(**kwargs)
    set_attr(kwargs, :server,       build_server)
    set_attr(kwargs, :game,         build_game)
    set_attr(kwargs, :country_code, "US")

    ServerVote.new(**kwargs)
  end

  def create_server_vote(...)
    build_server_vote(...).tap { it.save! }
  end

  # ServerWebhookConfig

  def build_server_webhook_config(**kwargs)
    set_attr(kwargs, :server, build_server)
    set_attr(kwargs, :url,    "https://game.company.com")
    set_attr(kwargs, :secret, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

    ServerWebhookConfig.new(**kwargs)
  end

  def create_server_webhook_config(...)
    build_server_webhook_config(...).tap { it.save! }
  end

  # ServerWebhookEvent

  def build_server_webhook_event(**kwargs)
    set_attr(kwargs, :server,  build_server)
    set_attr(kwargs, :type,    "test.event")
    set_attr(kwargs, :payload, "{}")
    set_attr(kwargs, :status,  ServerWebhookEvent::PENDING)

    ServerWebhookEvent.new(**kwargs)
  end

  def create_server_webhook_event(...)
    build_server_webhook_event(...).tap { it.save! }
  end

  # Session

  def build_session(**kwargs)
    set_attr(kwargs, :user,            build_user)
    set_attr(kwargs, :remote_ip,       "255.255.255.255")
    set_attr(kwargs, :expires_at,      30.days.from_now)
    set_attr(kwargs, :token_last_four, "abcd")
    set_attr(kwargs, :token_digest,    Digest::SHA256.hexdigest("token-#{random_chars}-#{kwargs[:token_last_four]}"))

    Session.new(**kwargs)
  end

  # Token

  def create_session(...)
    build_session(...).tap { it.save! }
  end

  def build_token(**kwargs)
    set_attr(kwargs, :user,            build_user)
    set_attr(kwargs, :purpose,         "email_confirmation")
    set_attr(kwargs, :expires_at,      30.days.from_now)
    set_attr(kwargs, :token_last_four, "abcd")
    set_attr(kwargs, :token_digest,    Digest::SHA256.hexdigest("token-#{random_chars}-#{kwargs[:token_last_four]}"))

    Token.new(**kwargs)
  end

  def create_token(...)
    build_token(...).tap { it.save! }
  end

  # User

  def build_user(**kwargs)
    set_attr(kwargs, :email, "user.#{random_chars}@upper.town")

    User.new(**kwargs)
  end

  def create_user(...)
    build_user(...).tap { it.save! }
  end

  private

  def set_attr(attrs, name, value)
    attrs[name] = value unless attrs.key?(name)
  end

  def random_chars
    SecureRandom.base58
  end
end
