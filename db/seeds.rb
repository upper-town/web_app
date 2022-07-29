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
  end

  private

  def add_servers
    10.times do
      FactoryBot.create(:server)
    end
  end
end

SeederAll.new.run
SeederDevelopmentOnly.new.run
