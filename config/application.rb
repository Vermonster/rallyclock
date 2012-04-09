require File.expand_path('../boot', __FILE__)

Bundler.require :default, ENV['RACK_ENV']
require 'active_support/all'

# database connection
Sequel.connect(ENV['DATABASE_URL'])

# models
Dir[File.expand_path('../../models/*.rb', __FILE__)].each do |f|
  require f
end

# api versions
Dir[File.expand_path('../../api/api_v*.rb', __FILE__)].each do |f|
  require f
end

require File.expand_path('../../api/api.rb', __FILE__)
require File.expand_path('../../app/rallyclock_app.rb', __FILE__)

