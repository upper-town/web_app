# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Dir[Rails.root.join("db", "seeds", "**", "*.rb")].each do |seeds_file|
  require seeds_file
end

Seeds::Development::Runner.new.call
