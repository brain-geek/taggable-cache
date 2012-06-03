require 'rubygems'
require 'bundler'
Bundler.require :default, :development

require 'capybara/rspec'

class Combustion::Application
  case ENV['CACHE_STORE']
  when 'redis'
    config.cache_store = :redis_store
  when 'memcached'
    config.cache_store = :mem_cache_store
  when 'file_store'
  end
end

Combustion.initialize!

require 'rspec/rails'
require 'capybara/rails'
require 'taggable_cache/railtie'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
