require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TaggableCache::Store do
  after :all do
    ENV.delete("REDIS_HOST")
    ENV.delete("REDIS_PORT")
  end

  it "should fall back to defaults if no settings given" do
    Redis.should_receive(:new).with(:host => '127.0.0.1', :port => 6379)

    TaggableCache::Store.new
  end

  it "should use ENV settings" do
    ENV["REDIS_HOST"] =  'hostname.lvh.me';
    ENV["REDIS_PORT"] =  '1234';

    Redis.should_receive(:new).with(:host => 'hostname.lvh.me', :port => 1234)

    TaggableCache::Store.new
  end
end