module TaggableCache
  module CacheStoreExtension
    extend ActiveSupport::Concern
    def self.included(base)
      base.class_eval do
        # Returns taggable store instance
        def taggable
          @taggable ||= TaggableCache.new_store
        end
        
        def write_with_taggable(name, value, options = nil)
          if !options.nil? && options.has_key?(:depends_on) 
            add_tags(name, *options[:depends_on])
          end

          write_without_taggable(name, value, options)
        end

        alias_method_chain :write, :taggable

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
        def expire_all
          #Load all the models
          Dir.glob(Rails.root + '/app/models/*.rb').each {|file| require file}
          
          ActiveRecord::Base.subclasses.each do |cls|
            expire_tags cls

            pk_name = cls.primary_key

            return if cls.unscoped.first.nil? #There is no sence in continuing, if model is empty

            last_id = cls.order(pk_name).last.try(pk_name.to_sym)
            first_id = 1

            (first_id..last_id).each do |id|
              expire_tags({:cls => cls, :id => id})
            end
          end
        end
      end
    end
  end
end