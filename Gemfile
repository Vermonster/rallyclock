source "http://rubygems.org"

gem "rack", "1.3.5"
gem "grape", :git => "https://github.com/intridea/grape.git", :branch => "frontier"
gem "json", "1.6.5"
gem "thin", "~> 1.3.1"
gem "sequel", "~> 3.34.1"
gem "pg", "~> 0.13.2"
gem "heroku", "~> 2.24.0"
gem "foreman", "~> 0.41.0"
gem "pry", "~> 0.9.8.4"
gem "database_cleaner", "~> 0.7.2"
gem "bcrypt-ruby", "~> 3.0.1", :require => 'bcrypt'
gem "activesupport", "~> 3.2.3", :require => 'active_support'

group :development do
  gem "guard"
  gem "guard-bundler"
  gem "guard-rack"
end

group :development, :test do
  gem "factory_girl", "~> 3.0.0"
end

group :test do
  gem "rspec"
  gem "rack-test"
  gem "rspec-core"
  gem "rspec-expectations"
  gem "rspec-mocks"
  gem "capybara", :git => "https://github.com/jnicklas/capybara.git"
end

