require 'taggable_cache/rails/observer'

class SimpleObserver < TaggableCache::Rails::Observer
  observe Page
end