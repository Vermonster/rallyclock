require File.expand_path('../config/environment', __FILE__)

Rack::Handler::Thin.run RallyClock::App.new, :Port => 3000

