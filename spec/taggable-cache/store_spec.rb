require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TaggableCache::Store do
  describe "connection to redis" do
  	it "should use default settings" do
      Redis.should_receive(:new)
      TaggableCache::Store.new
  	end
  end

  describe "adding tags" do
    before :all do
      @object = TaggableCache::Store.new
      @redis = Redis.new
      @redis.flushall
    end

    describe "id_for" do
      it "should use id and model name if saved activerecord object" do
        page = Page.create
        @object.id_for(page).should == "page-#{page.id}"
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

    describe "Redis interaction" do
      describe "add data" do
        it "should push data" do
          o1 = Object.new
          o2 = Object.new

          @object.should_receive(:id_for).with(o1).and_return('member1')
          @object.should_receive(:id_for).with(o2).and_return('member2')
          @object.should_receive(:id_for).with(nil).and_return(nil)

          @object.add('tag_name', o1, nil, o2)

          @redis.smembers(nil).should == []
          @redis.smembers('member1').should == ['tag_name']
          @redis.smembers('member2').should == ['tag_name']
        end
      end

      describe "get data" do
        it "should return keys and leave nothing behind" do
          page = Page.create

          @object.add('tag_name', page)
          @redis.smembers("page-#{page.id}").should == ['tag_name']
          
          @object.get(page).should == ['tag_name']
          @redis.smembers("page-#{page.id}").should be_empty
        end

        it "should do multi-get" do
          page = Page.create

          @object.add('tag_name', page)
          @object.add('tag2', Page)
          @redis.smembers("page-#{page.id}").should == ['tag_name']
          @redis.smembers("page").should == ['tag2']
          
          @object.get(page, Page).should == ['tag_name', 'tag2']
          @redis.smembers("page-#{page.id}").should be_empty
          @redis.smembers("page").should be_empty
        end
      end
    end
  end
end
