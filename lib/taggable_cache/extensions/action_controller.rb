module TaggableCache
  module ActionControllerExtension
    extend ActiveSupport::Concern
    def self.included(base)
      base.class_eval do
        def depends_on(*keys)
          _process_action_callbacks.find_all{|x| 
              (x.kind == :around) && 
              (x.raw_filter.is_a? ActionController::Caching::Actions::ActionCacheFilter) }.each do |callback|
            cache_path = callback.raw_filter.instance_variable_get('@cache_path')

            path_options = if cache_path.respond_to?(:call)
              instance_exec(self, &cache_path)
            else
              cache_path
            end

            path_options = ::ActionController::Caching::Actions::ActionCachePath.new(self, path_options || {}).path

            Rails.cache.add_tags(fragment_cache_key(path_options), *keys)
          end
        end        
      end
    end
  end  
end