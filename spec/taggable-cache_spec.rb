require 'spec_helper'

describe TaggableCache do
  describe "connection to redis" do
  	it "should use default settings" do
      Redis.should_receive(:new)
      TaggableCache.new
  	end
  end

  describe "adding tags" do
    before :all do
      @object = TaggableCache.new
    end
    describe "queque names" do
      it "should use id and model name if saved activerecord object" do
        @object.id_for(Page.create(:id => 1)).should == 'page-1'
      end

      it "should use id and model name if not saved activerecord object" do
        @object.id_for(Page.new(:id => 1)).should == 'page'
      end

      it "should use model name if model is passed" do
        @object.id_for(Page).should == 'page'
      end

      it "should return nil if unknown is passed" do
        @object.id_for(123).should be_nil
      end
    end

    pending "adding data to redis" do
      it "should push data" do

      end
    end
  end
end
