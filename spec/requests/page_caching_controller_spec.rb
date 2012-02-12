require 'spec_helper'

describe PageCachingController do
  before :each do 
    get 'page_caching/expire'
  end

  it "should be successful" do
    Page.should_receive :load_lot_of_data
    get 'page_caching/index'
    response.status.should be(200)
  end

  it "should run second test without cache" do
    Page.should_receive :load_lot_of_data
    get 'page_caching/index'
    response.status.should be(200)
  end
end
