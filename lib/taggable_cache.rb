require 'rails'

module TaggableCache
  def settings
    @@settings ||= {:store => :redis, :host => '127.0.0.1', :port => 6379}
  end

  def settings=(value)
    @@settings = value
  end

  def new_store
    params = settings.dup
    params.delete(:store)

    cls_name = "taggable_cache/store/#{settings[:store]}"
    cls = cls_name.camelize.constantize
    cls.send(:new, params)
  end

  extend self
end

require 'taggable_cache/store'
require 'taggable_cache/railtie'