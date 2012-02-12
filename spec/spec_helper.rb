require 'rubygems'
require 'bundler'
Bundler.require :default, :development

require 'capybara/rspec'

Combustion.initialize!

require 'rspec/rails'
require 'capybara/rails'
require 'taggable_cache/railtie'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
