class TaggableCache::Rails::Observer < ActiveRecord::Observer
  def event(model)
    Rails.cache.taggable.get(model, model.class).each do |m|
      Rails.cache.delete(m)
    end
  end

  alias :after_update :event
  alias :after_destroy :event
  alias :after_create :event
end