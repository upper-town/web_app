# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# rubocop:disable Rails/SkipsModelValidations
class SeedsDevelopment
  def call
    return unless Rails.env.development?

    delete_all
    insert_all
  end

  private

  def delete_all
    ServerStat.delete_all
    ServerVote.delete_all
    Server.delete_all
    App.delete_all
    UserAccount.delete_all
    User.delete_all

    AdminRolePermission.delete_all
    AdminUserRole.delete_all
    AdminRole.delete_all
    AdminPermission.delete_all
    AdminUser.delete_all
  end

  def insert_all
    create_admin_users

    user_ids = create_users
    user_account_ids = create_user_accounts(user_ids)

    app_ids = create_apps
    server_ids = create_servers(app_ids)

    create_server_votes(app_ids, server_ids, user_account_ids)

    consolidate_server_vote_counts(server_ids)
    consolidate_server_ranking_numbers(app_ids)
  end

  def create_admin_users
    admin_user_hashes = 1.upto(10).map do |n|
      {
        email: "admin.user.#{n}@upper.town",
        encrypted_password: Devise::Encryptor.digest(User, 'testpass'),
        confirmed_at: Time.current
      }
    end
    admin_user_hashes.append(
      {
        email: 'super.admin.user@upper.town',
        encrypted_password: Devise::Encryptor.digest(User, 'testpass'),
        confirmed_at: Time.current
      }
    )
    result = AdminUser.insert_all(admin_user_hashes)

    result.rows.flatten # admin_user_ids
  end

  def create_users
    user_hashes = 1.upto(10).map do |n|
      {
        uuid: SecureRandom.uuid,
        email: "user.#{n}@upper.town",
        encrypted_password: Devise::Encryptor.digest(User, 'testpass'),
        confirmed_at: Time.current,
      }
    end
    result = User.insert_all(user_hashes)

    result.rows.flatten # user_ids
  end

  def create_user_accounts(user_ids)
    user_account_hashes = user_ids.map do |user_id|
      {
        uuid: SecureRandom.uuid,
        user_id: user_id
      }
    end
    result = UserAccount.insert_all(user_account_hashes)

    result.rows.flatten # user_account_ids
  end

  def create_apps
    app_hashes = [
      {
        uuid:        SecureRandom.uuid,
        slug:        'minecraft',
        name:        'Minecraft',
        kind:        App::GAME,
        site_url:    'https://www.minecraft.net/',
        description: '',
        info:        '',
      },
      {
        uuid:        SecureRandom.uuid,
        slug:        'perfect-world-international',
        name:        'Perfect World International (PWI)',
        kind:        App::GAME,
        site_url:    'https://www.arcgames.com/en/games/pwi',
        description: '',
        info:        '',
      }
    ]
    result = App.insert_all(app_hashes)

    result.rows.flatten # app_ids
  end

  def create_servers(app_ids)
    server_ids = []

    app_ids.map do |app_id|
      server_hashes = 1.upto(10).map { |n| build_attributes_for_server(app_id, n) }
      result = Server.insert_all(server_hashes)

      server_ids.concat(result.rows.flatten)
    end

    server_ids
  end

  def generate_country_code(reject_values = [])
    reject_values = Array(reject_values)

    [
      'US',
      'BR',
    ].reject do |country_code|
      reject_values.include?(country_code)
    end.sample
  end

  def build_attributes_for_server(app_id, n)
    uuid = SecureRandom.uuid
    name = "#{Faker::Lorem.words(number: 3).join(' ').titleize}-#{n}"
    country_code = generate_country_code
    site_url = "https://nice-server-#{n}.example.com/"
    banner_image_url = Faker::Avatar.image(slug: SecureRandom.uuid, size: '750x150', bgset: ['bg1', 'bg2'].sample)
    description = Faker::Lorem.sentence(word_count: 30)
    info = [
      Faker::Lorem.paragraphs(number: 10).join(' '),
      Faker::Lorem.paragraphs(number: 15).join(' '),
      Faker::Lorem.paragraphs(number: 10).join(' '),
    ].join("\n\n")

    {
      app_id: app_id,
      uuid: uuid,
      name: name,
      country_code: country_code,
      site_url: site_url,
      banner_image_url: banner_image_url,
      description: description,
      info: info,
    }
  end

  def create_server_votes(app_ids, server_ids, user_account_ids)
    server_values = Server.where(id: server_ids).pluck(:id, :country_code, :app_id)

    server_values.each do |(server_id, server_country_code, server_app_id)|
      server_vote_hashes = []

      (ServerStat::MIN_PAST_TIME.beginning_of_year.to_date..Date.current.end_of_year).each do |day_date|
        # Generate a country_code for the server's vote that's different from the server's country_code 1/5 of the time.
        # The idea is to simulate the server occasionally changed its country_code
        # so it received some votes with different country_codes
        country_code = [generate_country_code(server_country_code), *Array.new(4) { server_country_code }].sample

        # Generate a app_id for the server's vote that's different from the server's app_id 1/5 of the time.
        # The idea is to simulate the server occasionally changed its app_id
        # so it received some votes with different app_ids.
        app_id = [(app_ids - [server_app_id]).sample, *Array.new(4) { server_app_id }].sample

        SecureRandom.random_number(1..10).times do
          server_vote_hashes << {
            uuid:            SecureRandom.uuid,
            user_account_id: user_account_ids.sample,
            server_id:       server_id,
            country_code:    country_code,
            app_id:          app_id,
            created_at:      day_date,
            updated_at:      day_date,
          }
        end
      end

      ServerVote.insert_all(server_vote_hashes)
    end
  end

  def consolidate_server_vote_counts(server_ids)
    # Do not consolidate votes for 1/10 of the servers.
    # The idea is to simulate a scenario in which some servers haven't had their
    # votes consolidated yet.
    selected_server_ids = server_ids.shuffle.drop(server_ids.size / 10)

    selected_server_ids.each do |server_id|
      Servers::ConsolidateVoteCountsJob.new.perform(server_id, 'all')
    end
  end

  def consolidate_server_ranking_numbers(app_ids)
    app_ids.each do |app_id|
      Servers::ConsolidateRankingsJob.new.perform(app_id, 'all')
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations

SeedsDevelopment.new.call
