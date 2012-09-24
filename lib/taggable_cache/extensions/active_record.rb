module TaggableCache
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
                  Rails.cache.expire_tags(model, model.class)
                end)
      end
    end
  end
end