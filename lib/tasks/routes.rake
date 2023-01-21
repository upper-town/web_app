# frozen_string_literal: true

desc 'Alias to `bundle exec rails routes`'
task routes: :environment do
  puts `bundle exec rails routes`
end
