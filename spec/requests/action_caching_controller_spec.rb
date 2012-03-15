require 'spec_helper'

describe ActionCachingController do
  describe "simple" do
    before :each do 
      Rails.cache.clear
      Redis.new.flushall
      @url = 'action_caching/index'
    end

    it "should be successful" do
      Page.should_receive :load_lot_of_data
      get @url
      response.status.should be(200)      
    end

    it "should run second test with cache deletion" do
      Page.should_receive(:load_lot_of_data).once
      get @url
      response.status.should be(200)

      get @url
      response.status.should be(200)

      Page.should_receive(:load_lot_of_data).once
      Page.create
      get @url
      response.status.should be(200)
    end
  end

  describe "with cache_path" do
    before :each do 
      Rails.cache.clear
      Redis.new.flushall
      @url = 'action_caching/cp'
    end

    it "should be successful" do
      Page.should_receive :load_lot_of_data
      get @url
      response.status.should be(200)
    end

    it "should run second test with cache deletion" do
      Page.should_receive(:load_lot_of_data).once
      get @url
      response.status.should be(200)

      get @url
      response.status.should be(200)

      Page.should_receive(:load_lot_of_data).once
      Page.create
      get @url
      response.status.should be(200)
    end
  end
end
