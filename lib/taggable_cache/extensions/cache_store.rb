module TaggableCache
  module CacheStoreExtension
    extend ActiveSupport::Concern

    def taggable
      @taggable ||= TaggableCache.new_store
    end

    # Add tag to cache element
    def add_tags(key, *params)
      taggable.add(key, *params)
    end

    # Expire cache elements by list of keys
    def expire_tags(*params)
      taggable.get(*params).each do |m|
        self.delete(m)
      end
    end

    # Expire all cache entries availible for taggable
    # WARNING: this is expensive function and may take VERY long on big data
    def expire_all
      #Load all the models
      Dir.glob(Rails.root + '/app/models/*.rb').each {|file| require file}
      
      ActiveRecord::Base.subclasses.each do |cls|
        expire_tags cls

        pk_name = cls.primary_key

        return if cls.unscoped.first.nil? #There is no sence in continuing, if model is empty

        last_id = cls.order(pk_name).last.try(pk_name.to_sym)

        #hardcoded value for first record
        first_id = 1

        (first_id..last_id).each do |id|
          expire_tags({:cls => cls, :id => id})
        end
      end
    end

    included do |base|
      base.class_eval do
        # Returns taggable store instance
        def write_with_taggable(name, value, options = {})
          if self.respond_to? :namespaced_key
            cache_key = namespaced_key(name, options)
          else
            cache_key = name
          end
          
          add_tags(cache_key, *options[:depends_on]) if options.has_key?(:depends_on) 

          write_without_taggable(name, value, options)
        end

        alias_method_chain :write, :taggable
      end
    end
  end
end