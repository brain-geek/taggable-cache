module TaggableCache::Store
  class Base
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

    def is_scope?(scope)
      (scope.is_a? ActiveRecord::Relation) || (scope.is_a? Arel::SelectManager)
    end

    def in_scope?(scope, object)
      return false unless object.persisted?

      query = scope.where(scope.froms.first[:id].eq(object.id)).to_sql

      object.class.connection.select_all(query).length > 0
    end

    def initialize
      raise ActionController::NotImplemented.new      
    end

    def add(tag, *members)
      raise ActionController::NotImplemented.new
    end

    def get(*members)
      raise ActionController::NotImplemented.new
    end

    def add_scope(tag, scope)
      raise ActionController::NotImplemented.new
    end

    def get_scope(*members)
      raise ActionController::NotImplemented.new
    end
  end
end