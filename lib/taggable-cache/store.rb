require "redis"

class TaggableCache::Store
  def initialize
    @redis = Redis.new
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
    else
      nil
    end
  end

  def add(tag, *members)
    members.each do |element|
      ident = id_for(element)
      @redis.sadd ident, tag unless ident.nil?
    end
  end

  def get(tag)
    ident = id_for(tag)
    elements = @redis.smembers(ident)
    @redis.del(ident)
    elements
  end
end