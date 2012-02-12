require 'spec_helper'

describe FragmentCachingController do
  before :each do 
    get 'fragment_caching/expire'
    @url = 'fragment_caching/index'
  end

  it "should be successful" do
    Page.should_receive :load_lot_of_data
    get @url
    response.status.should be(200)      
  end

  it "should run second test without cache" do
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
