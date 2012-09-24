require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TaggableCache::Store do
  def new_cache_instance
    Rails.cache.class.new Rails.cache.options
  end

  it "should have default variables" do
    TaggableCache.settings[:store].should == :redis
    TaggableCache.settings[:host].should == '127.0.0.1'
    TaggableCache.settings[:port].should == 6379
  end

  it "should fall back to defaults if no settings given" do
    Redis.should_receive(:new).with(:host => '127.0.0.1', :port => 6379)

    new_cache_instance.taggable
  end

  it "should use ENV settings" do
    TaggableCache.settings = {
      :store => :redis, 
      :host => 'hostname.lvh.me', 
      :port => 1234
    }

    Redis.should_receive(:new).with(:host => 'hostname.lvh.me', :port => 1234)

    new_cache_instance.taggable
  end

  it "should use 'store' option to detect which class to create" do
    TaggableCache.settings = {
      :store => :base, 
      :first => 'hostname.lvh.me', 
      :second => 1234,
      :third => 'asads'
    }

    TaggableCache::Store::Base.should_receive(:new).with(:first => 'hostname.lvh.me', :second => 1234, :third => 'asads')

    new_cache_instance.taggable
  end
end