require "redis"
require "digest/md5"

module TaggableCache::Store
  class Redis < TaggableCache::Store::Base
    def initialize(attrs = {})
      @redis = ::Redis.new attrs
    end

    # Add tag to multiple cache entries
    def add(tag, *members)
      members.each do |element|
        add_scope(tag, element) if is_scope? element
        ident = id_for(element)
        @redis.sadd ident, tag unless ident.nil?
      end
    end

    # Get cache entries by given keys.
    # This list is cleaned up after request:
    #   page = Page.create
    #   store.add('tag_name', page)
    #   store.get_scope(p).should == ['tag_name']
    #   store.get_scope(p).should == []
    def get(*members)
      keys = members.map { |tag| id_for(tag) }
      elements = @redis.sunion(keys)
      @redis.del(keys)
      
      scopes = members.delete_if {|a| not a.is_a? ActiveRecord::Base}

      elements += get_scope(*scopes)
      elements.flatten.uniq.compact
    end

    protected
    def add_scope(tag, scope)
      scope = scope.arel if scope.is_a? ActiveRecord::Relation
      table_name = scope.froms.first.name
      query_fingerprint = Digest::MD5.hexdigest(scope.to_sql)

      @redis.sadd "#{table_name}-scopes", "#{query_fingerprint}"
      @redis.set "query-#{query_fingerprint}", Marshal.dump(scope)
    end

    def get_scope(*members)
      keys = members.delete_if{|a| not a.is_a? ActiveRecord::Base }.map do |object|

        table_redis_key = "#{object.class.table_name}-scopes"

        @redis.smembers(table_redis_key).map do |scope_key|
          scope = Marshal.restore(@redis.get("query-#{scope_key}"))

          if in_scope?(scope, object)
            ident = "query-keys-#{scope_key}"
            elements = @redis.smembers(ident)
            @redis.del(ident)
            elements
          end
        end
      end
      
      keys
    end
  end
end