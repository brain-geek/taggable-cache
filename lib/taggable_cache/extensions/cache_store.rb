module TaggableCache
  module CacheStoreExtension
    extend ActiveSupport::Concern
    def self.included(base)
      base.class_eval do
        def taggable
          @taggable ||= ::TaggableCache::Store.new
        end
        
        def write_with_taggable(name, value, options = nil)
          if !options.nil? && options.has_key?(:depends_on) 
            add_tags(name, *options[:depends_on])
          end

          write_without_taggable(name, value, options)
        end

        alias_method_chain :write, :taggable

        def add_tags(key, *params)
          taggable.add(key, *params)
        end

        def delete_by_tags(*params)
          taggable.get(*params).each do |m|
            self.delete(m)
          end

          taggable.get_scope(*(params.delete_if{|a| not a.is_a? ActiveRecord::Base})).each do |m|
            self.delete(m)
          end
        end

        def expire_all
          #Load all the models
          Dir.glob(Rails.root + '/app/models/*.rb').each {|file| require file}
          
          ActiveRecord::Base.subclasses.each do |cls|
            delete_by_tags cls

            pk = cls.primary_key

            unless cls.first.nil?
              range = 1..cls.order(pk).last.try(:id)

              range.each do |i|
                delete_by_tags(cls.find_by_id(i) || cls.new(:id => i))
              end
            end
          end
        end
      end
    end
  end
end