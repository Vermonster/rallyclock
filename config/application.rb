require File.expand_path('../boot', __FILE__)

Bundler.require :default, ENV['RACK_ENV']

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: 'localhost',
  database: "rallyclock_#{ENV['RACK_ENV']}"
)

Dir[File.expand_path('../../api/api_v*.rb', __FILE__)].each do |f|
  require f
end

require File.expand_path('../../api/api.rb', __FILE__)
require File.expand_path('../../app/rallyclock_app.rb', __FILE__)

