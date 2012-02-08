require 'rubygems'
require 'bundler'
require 'taggable-cache'

Bundler.require :default, :development

Combustion.initialize!

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end