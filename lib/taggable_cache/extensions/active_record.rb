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
      [:after_commit, :after_rollback].each do |event|
        base.send(event, proc { |model| binding.pry; Rails.cache.expire_tags(model, model.class) })
      end
    end
  end
end
