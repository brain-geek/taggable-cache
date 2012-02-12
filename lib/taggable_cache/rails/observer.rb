module TaggableCache::Rails
  class Observer < ActiveRecord::Observer
    def event(model)
      Rails.cache.delete_keys(model, model.class)
    end

    alias :after_update :event
    alias :after_destroy :event
    alias :after_create :event
  end
end