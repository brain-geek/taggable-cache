require 'spec_helper'

describe TaggableCache do
  describe "should connect to redis" do
  	it "should use default settings" do
      Redis.should_receive(:new)
      TaggableCache.new
  	end
  end
end
