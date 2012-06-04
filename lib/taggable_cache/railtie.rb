require 'taggable_cache/extensions/action_controller'
require 'taggable_cache/extensions/active_record'
require 'taggable_cache/extensions/cache_store'

module TaggableCache
  class Railtie < ::Rails::Railtie
    initializer "taggable_cache" do |app|
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.send :include, TaggableCache::ActiveRecordExtension
        ::ActionController::Base.send :include, TaggableCache::ActionControllerExtension        

        ::ActiveSupport::Cache::Store.send :include, TaggableCache::CacheStoreExtension
        ::ActiveSupport::Cache::RedisStore.send :include, TaggableCache::CacheStoreExtension if defined? ::ActiveSupport::Cache::RedisStore
      end
    end
  end  
end
