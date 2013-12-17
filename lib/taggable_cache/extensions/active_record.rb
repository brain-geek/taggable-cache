module TaggableCache
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def inherited(kls)
        kls.send(:include, TaggableCache::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
        super
      end      
    end

    included do
      # Existing subclasses pick up the model extension as well
      self.descendants.each do |kls|
        kls.send(:include, TaggableCache::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
      end
    end
  end

  module ActiveRecordModelExtension
    extend ActiveSupport::Concern
    def self.included(base)
        [:before_update, :before_destroy, :after_commit].each do |event|
          base.send(event, Proc.new do |model|
                  Rails.cache.expire_tags(model, model.class)
                end)
      end
    end
  end
end
