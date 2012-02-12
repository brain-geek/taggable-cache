ActiveSupport::Cache::Store.class_eval do
  def taggable
    @taggable ||= ::TaggableCache::Store.new
  end

  alias_method :original_write, :write

  def write(name, value, options = nil)
    if !options.nil? && options.has_key?(:depends_on) 
      taggable.add(name, *options[:depends_on])
      options.delete(:depends_on)
    end

    original_write(name, value, options)
  end

  def delete_keys(*params)
    taggable.get(*params).each do |m|
      self.delete(m)
    end
  end
end

module TaggableCache
  class Railtie < ::Rails::Railtie
  end  
end
