require 'rubygems'

require 'rack/test'

require File.expand_path("../sequel_matchers", __FILE__)

require File.expand_path("../../config/environment", __FILE__)

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec

  config.include SequelMatchers

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end
 
  config.after do
    DatabaseCleaner.clean
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end   
end

require 'capybara/rspec'
Capybara.configure do |config|
  config.app = RallyClock::App.new
end

