module TaggableCache::Store
  class Base
    # Returns taggable cache unique id for object
    def id_for(obj)
      if obj.is_a? Class
        obj.to_s.downcase
      elsif obj.is_a? ActiveRecord::Base
        if obj.persisted?
          "#{obj.class.to_s.downcase}-#{obj.id}" 
        else
          id_for(obj.class)
        end
      elsif obj.is_a? Arel::SelectManager
        "query-keys-#{Digest::MD5.hexdigest(obj.to_sql)}"
      elsif obj.is_a? ActiveRecord::Relation
        id_for(obj.arel)
      elsif obj.is_a? String
        "string_#{obj.to_s}"
      elsif obj.is_a? Hash
        if obj.include?(:cls) && obj.include?(:id)
          "#{obj[:cls].to_s.downcase}-#{obj[:id]}"
        else
          nil
        end
      else
        nil
      end
    end

    # Checks if this is AR scope
    def is_scope?(scope)
      (scope.is_a? ActiveRecord::Relation) || (scope.is_a? Arel::SelectManager)
    end

    # Checks if object is in given scope
    def in_scope?(scope, object)
      return false unless object.persisted?

      query = scope.where(scope.froms.first[:id].eq(object.id)).to_sql

      object.class.connection.select_all(query).length > 0
    end

    #:nodoc:
    def initialize(attrs = {})
      raise ActionController::NotImplemented.new      
    end

    #:nodoc:
    def add(tag, *members)
      raise ActionController::NotImplemented.new
    end

    #:nodoc:
    def get(*members)
      raise ActionController::NotImplemented.new
    end
  end
end