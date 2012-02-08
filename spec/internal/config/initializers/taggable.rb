#combustion uses rails file cache, so we make magic on it
require 'taggable-cache/rails'

ActiveSupport::Cache::FileStore.class_eval do
  include TaggableCache::Rails::Cache
end

#Listing all models with enabled taggable cache
# TaggableCache::Rails::Observer.observe Page

Combustion::Application.config.active_record.observers = :simple_observer