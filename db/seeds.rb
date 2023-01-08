# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

class SeedsDevelopment
  def call
    return unless Rails.env.development?

    Rails.logger.info 'Seeding data for development environment'

    add_servers
    add_users
    add_admin_users
  end

  private

  def add_servers
    1.upto(10) do |n|
      Server.create!(
        name: "Server #{n}",
        site_url: "https://server-#{n}.example.com/",
        uuid: SecureRandom.uuid,
      )
    end
  end

  def add_users
    1.upto(100) do |n|
      User.create!(
        email: "user.#{n}@example.com",
        password: 'testpass',
        confirmed_at: Time.current,
        uuid: SecureRandom.uuid
      )
    end
  end

  def add_admin_users
    AdminUser.create!(
      email: 'super.admin.user@example.com',
      password: 'testpass',
      confirmed_at: Time.current
    )
    AdminUser.create!(
      email: 'some.admin.user@example.com',
      password: 'testpass',
      confirmed_at: Time.current
    )
  end
end

SeedsDevelopment.new.call
