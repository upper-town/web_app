# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require "factory_bot_rails"

class SeederAll
  def run
    return if Rails.env.test?

    Rails.logger.info "Seeding data for all environments"
  end
end

class SeederDevelopmentOnly
  def run
    return unless Rails.env.development?

    Rails.logger.info "Seeding development-only data"

    add_servers
    add_users
    add_admin_users
  end

  private

  def add_servers
    10.times do
      FactoryBot.create(:server)
    end
  end

  def add_users
    FactoryBot.create(:user, email: 'user.1@example.com', password: 'testpass')
    FactoryBot.create(:user, email: 'user.2@example.com', password: 'testpass')
    FactoryBot.create(:user, email: 'user.3@example.com', password: 'testpass')
  end

  def add_admin_users
    FactoryBot.create(:admin_user, email: 'admin.user.1@example.com', password: 'testpass')
  end
end

SeederAll.new.run
SeederDevelopmentOnly.new.run
