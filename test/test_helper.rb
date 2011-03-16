# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
ENV["RAILS_VER"] ||= "2"

require File.expand_path("../dummy#{ENV["RAILS_VER"]}/config/environment.rb",  __FILE__)

if ENV["RAILS_VER"] == "2"
  require "test_help" 
else
  require "rails/test_help"
end

require 'redgreen'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy#{ENV["RAILS_VER"]}/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
