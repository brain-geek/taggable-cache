ActiveSupport::Cache::Store.class_eval do
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
  end
end

ActionController::Base.class_eval do
  def depends_on(*params)
    key_name = fragment_cache_key(::ActionController::Caching::Actions::ActionCachePath.new(self).path)
    Rails.cache.add_tags(key_name, *params)
  end
end

module TaggableCache
  class Railtie < ::Rails::Railtie
  end  
end
