require 'spec_helper'

describe ActionCachingController do
  before :each do 
    get 'action_caching/expire'
  end

  it "should be successful" do
    Page.should_receive :load_lot_of_data
    get 'action_caching/index'
    response.status.should be(200)
  end

  it "should run second test without cache" do
    Page.should_receive :load_lot_of_data
    get 'action_caching/index'
    response.status.should be(200)
  end
end
