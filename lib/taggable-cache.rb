require "redis"

class TaggableCache
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
end