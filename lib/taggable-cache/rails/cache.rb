module TaggableCache::Rails::Cache
  def taggable
    @taggable ||= ::TaggableCache::Store.new
  end

  def write(name, value, options = nil)
    if options.has_key?(:depends_on)
      taggable.add(name, *options[:depends_on])
      #@taggable.
      options.delete(:depends_on)
    end

    super(name, value, options)
  end
end
