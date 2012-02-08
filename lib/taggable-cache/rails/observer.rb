class TaggableCache::Rails::Observer < ActiveRecord::Observer
  def event(model)
    #binding.pry

    Rails.cache.taggable.get(model).each do |m|
      Rails.cache.delete(m)
    end

    Rails.cache.taggable.get(model.class).each do |m|
      Rails.cache.delete(m)
    end    
  end

  alias :after_update :event
  alias :after_destroy :event
  alias :after_create :event
end