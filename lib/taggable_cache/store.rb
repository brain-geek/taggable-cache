require "redis"
require "digest/md5"

class TaggableCache::Store
  def initialize
    @redis = Redis.new  :host => ENV['REDIS_HOST'] || '127.0.0.1',
                        :port => ENV['REDIS_PORT'] ? ENV['REDIS_PORT'].to_i : 6379
  end

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
    else
      nil
    end
  end

  def add(tag, *members)
    members.each do |element|
      add_scope(tag, element) if is_scope? element
      ident = id_for(element)
      @redis.sadd ident, tag unless ident.nil?
    end
  end

  def get(*members)
    members.map do |tag|
      ident = id_for(tag)
      elements = @redis.smembers(ident)
      @redis.del(ident)
      elements
    end.flatten.compact
  end

  def is_scope?(scope)
    (scope.is_a? ActiveRecord::Relation) || (scope.is_a? Arel::SelectManager)
  end

  def add_scope(tag, scope)
    scope = scope.arel if scope.is_a? ActiveRecord::Relation
    table_name = scope.froms.first.name
    query_fingerprint = Digest::MD5.hexdigest(scope.to_sql)

    @redis.sadd "#{table_name}-scopes", "#{query_fingerprint}"
    @redis.set "query-#{query_fingerprint}", Marshal.dump(scope)
  end

  def in_scope(scope, object)
    return false unless object.persisted?

    query = scope.where(scope.froms.first[:id].eq(object.id)).to_sql

    object.class.connection.select_all(query).length > 0
  end

  def get_scope(*members)
    keys = members.delete_if{|a| not a.is_a? ActiveRecord::Base }.map do |object|

      table_redis_key = "#{object.class.table_name}-scopes"

      @redis.smembers(table_redis_key).map do |scope_key|
        scope = Marshal.restore(@redis.get("query-#{scope_key}"))

        if in_scope(scope, object)
          ident = "query-keys-#{scope_key}"
          elements = @redis.smembers(ident)
          @redis.del(ident)
          elements
        end
      end
    end
    
    keys.flatten.compact
  end
end