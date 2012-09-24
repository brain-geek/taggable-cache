require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TaggableCache::Store do
  describe "connection to redis" do
  	it "should use default settings" do
      Redis.should_receive(:new)
      TaggableCache::Store::Redis.new
  	end
  end

  describe "adding tags" do
    before :all do
      @object = TaggableCache::Store::Redis.new
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

      it "should make hash of arel/AR::relation object" do
        @object.id_for(Page.order(:id)).should == @object.id_for(Page.order(:id).arel)
        @object.id_for(Page.order(:id)).should_not be_nil

        @object.id_for(Page.order(:id)).should_not == @object.id_for(Page.order(:name).arel)
      end

      it "should try to parse well-formatted hash to AR object key" do
        key = @object.id_for(page = Page.create)
        key.should == @object.id_for({:cls => :page, :id => page.id})
        key.should == @object.id_for({:cls => Page, :id => page.id})
      end

      it "should ignore bad-formatted hashes" do
        @object.id_for({:cls => :page}).should be_nil
        @object.id_for({:cls => Page}).should be_nil
        @object.id_for({:id => 543}).should be_nil
        @object.id_for({:sdfasdf => 345}).should be_nil
      end

      it "should allow string values as keys" do
        @object.id_for('lorem').should == 'string_lorem'
      end
    end

    describe "is_scope?" do
      it "is not AR object or class" do
        @object.is_scope?(Page).should be_false
        @object.is_scope?(Page.create).should be_false
      end

      it "is arel object or AR relation" do
        @object.is_scope?(Page.order(:id)).should be_true
        @object.is_scope?(Page.order(:id).arel).should be_true
      end
    end

    describe "scope flow" do
      before :each do 
        @redis.flushall
      end

      it "should add scope to model-specific set" do
        @redis.smembers('pages-scopes').should == []
        @object.add('tag_name', Page.where('name' => 'bob'))
        @redis.smembers('pages-scopes').count.should == 1
      end

      it "should be a marshalized arel object in model-specific set" do
        Page.create(:name => 'bob')
        @object.add('tag_scoped', Page.where('name' => 'bob'))
        key = @redis.smembers('pages-scopes').first
        query = @redis.get("query-#{key}")
        Marshal.restore(query).should be_kind_of Arel::SelectManager

        @redis.smembers("query-keys-#{key}").should == ['tag_scoped']
      end

      it "should process 'in_scope?' right way" do
        bob = Page.create(:name => 'bob')
        jack = Page.create(:name => 'jack')

        @object.in_scope?(Page.where(:name => 'bob'), bob).should be_true
        @object.in_scope?(Page.where(:name => 'bob'), jack).should be_false

        @object.in_scope?(Page.order(:id), Page.create).should be_true

        #unsaved obj(without id)
        @object.in_scope?(Page.order(:id), Page.new).should be_false
      end

      describe "get_scope" do
        it "should return keys and leave nothing behind" do
          #query to get all keys
          p = Page.create
          page = Page.order(:id) 

          @object.add('tag_name', page)
          @object.get_scope(p).should == ['tag_name']
          @object.get_scope(p).should == []
        end

        it "should do multi-get" do
          bob = Page.create(:name => 'bob')
          jack = Page.create(:name => 'jack')
          ian = Page.create(:name => 'ian')

          @object.add('bob', Page.where(:name => 'bob'))
          @object.add('jack', Page.where(:name => 'jack'))
          @object.add('ian', Page.where(:name => 'ian'))

          @object.get_scope(bob,jack).should == ['bob', 'jack']
          @object.get_scope(bob,jack).should == []
          @object.get_scope(ian).should == ['ian']
        end
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
