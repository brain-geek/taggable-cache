require "redis"


class TaggableCache
  def initialize
    @redis = Redis.new
  end

  
end