require 'rubygems'
require 'bundler'
require 'taggable_cache'

Bundler.require :default, :development

require 'capybara/rspec'

Combustion.initialize!

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
