module TaggableCache
  module CacheStoreExtension
    extend ActiveSupport::Concern
    def self.included(base)
      base.class_eval do
        def taggable
          @taggable ||= ::TaggableCache::Store.new
        end

        alias_method :original_write, :write

        def write(name, value, options = nil)
          if !options.nil? && options.has_key?(:depends_on) 
            add_tags(name, *options[:depends_on])
          end

          original_write(name, value, options)
        end

        def add_tags(key, *params)
          taggable.add(key, *params)
        end

        def delete_by_tags(*params)
          taggable.get(*params).each do |m|
            self.delete(m)
          end

          taggable.get_scope(*(params.delete_if{|a| not a.is_a? ActiveRecord::Base})).each do |m|
            self.delete(m)
          end
        end
      end
    end
  end

  module ActionControllerExtension
    extend ActiveSupport::Concern
    def self.included(base)
      base.class_eval do
        def depends_on(*params)
          key_name = fragment_cache_key(::ActionController::Caching::Actions::ActionCachePath.new(self).path)
          Rails.cache.add_tags(key_name, *params)
        end        
      end
    end
  end  

  module ActiveRecordExtension
    extend ActiveSupport::Concern
    included do
      # Future subclasses will pick up the model extension
      class << self
        def inherited_with_taggable(kls)
          inherited_without_taggable kls
          kls.send(:include, TaggableCache::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
        end
        alias_method_chain :inherited, :taggable
      end

      # Existing subclasses pick up the model extension as well
      self.descendants.each do |kls|
        kls.send(:include, TaggableCache::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
      end
    end
  end


  module ActiveRecordModelExtension
    extend ActiveSupport::Concern
    def self.included(base)
        [:after_update, :before_update, :before_destroy, :after_create].each do |event|
          base.send(event, Proc.new do |model|
                  Rails.cache.delete_by_tags(model, model.class)
                end)
      end
    end
  end
end