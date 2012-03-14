require 'taggable_cache/extensions'

module TaggableCache
  class Railtie < ::Rails::Railtie
    initializer "taggable_cache" do |app|
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.send :include, TaggableCache::ActiveRecordExtension
        ::ActiveSupport::Cache::Store.send :include, TaggableCache::CacheStoreExtension
        ::ActionController::Base.send :include, TaggableCache::ActionControllerExtension        
      end
    end
  end  
end
