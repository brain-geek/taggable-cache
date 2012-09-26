require 'rails'

module TaggableCache
  def settings
    @@settings ||= {:store => :redis, :host => '127.0.0.1', :port => 6379}
  end

  def settings=(value)
    @@settings = value
  end

  # Creates new Taggable store instance based on current settings
  def new_store
    params = settings.dup
    params.delete(:store)
    
    cls = Store::const_get(settings[:store].to_s.camelize)

    cls.send(:new, params)
  end

  extend self
end

require 'taggable_cache/store'
require 'taggable_cache/railtie'