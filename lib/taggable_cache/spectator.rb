class TaggableCache::Spectator < ActiveRecord::Observer
  def event(model)
    Rails.cache.delete_by_tags(model, model.class)
  end

  alias :after_update :event
  alias :after_destroy :event
  alias :after_create :event
end