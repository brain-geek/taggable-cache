require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'TaggableCache::Rails::Cache' do
  before :all do
    @object = TaggableCache::Store::Redis.new
    @page_object = Page.create!
  end

  before :each do 
    Redis.new.flushall
  end

  describe "Rails.cache.write integration" do
    it "adds key to store" do
      Rails.cache.write('key', 'value', :depends_on => [@page_object])

      @object.get(@page_object).should == ['key']
    end

    it "does simple writes" do
      Rails.cache.write 'ipsum', 'lorem'
      Rails.cache.read('ipsum').should == 'lorem'
    end
  end

  describe "Rails.cache.fetch integration" do
    it "adds key to store" do
      Rails.cache.fetch('fetch_key', :depends_on => @page_object) do
        'value1'
      end

      @object.get(@page_object).should == ['fetch_key']
    end

    it "does simple expires" do
      Rails.cache.fetch 'ftch_ipsum', :depends_on => @page_object do 
        'lorem ipsum'
      end

      Rails.cache.read('ftch_ipsum').should == 'lorem ipsum'

      @page_object.name = 'dfgsdgsdfgsdfg'
      @page_object.save!

      Rails.cache.read('ftch_ipsum').should be_nil
    end

    it "does class expires" do
      Rails.cache.fetch 'ftch_ipsum2', :depends_on => Page do 
        'lorem ipsum di'
      end

      Rails.cache.read('ftch_ipsum2').should == 'lorem ipsum di'

      @page_object.save!

      Rails.cache.read('ftch_ipsum2').should be_nil
    end

    it "does combined expires" do
      page = Page.create!
      Rails.cache.fetch 'ftch_ipsum3', :depends_on => [page, @page_object] do 
        'lorem ipsum di'
      end

      Rails.cache.read('ftch_ipsum3').should == 'lorem ipsum di'

      @page_object.save!

      Rails.cache.read('ftch_ipsum3').should be_nil

      Rails.cache.fetch 'ftch_ipsum3', :depends_on => [page, @page_object] do 
        'lorem ipsum di'
      end

      Rails.cache.read('ftch_ipsum3').should == 'lorem ipsum di'

      page.save!

      Rails.cache.read('ftch_ipsum3').should be_nil      
    end
  end

  describe "Activerecord integration" do    
    it "object change" do
      Rails.cache.write('key', 'value', :depends_on => [@page_object])

      Rails.cache.read('key').should == 'value'

      #save should trigger deleting depending cache entries
      @page_object.name = @page_object.name.to_s + '1'
      @page_object.save!

      Rails.cache.read('key').should be_nil
    end

    it "model change" do
      Rails.cache.write('lorem', 'impsum', :depends_on => [Page])

      Rails.cache.read('lorem').should == 'impsum'

      Page.create

      Rails.cache.read('lorem').should be_nil
    end

    describe  "scope change" do
      it "should not drop if changes are unrelated" do
        Rails.cache.write('lorem', 'impsum', :depends_on => [Page.where(:name => 'bob')])
        Rails.cache.read('lorem').should == 'impsum'

        page = Page.create(:name => 'jack')
        page.name = 'alice'
        page.save!
        Page.delete(page.id)

        Rails.cache.read('lorem').should == 'impsum'
      end

      it "should drop if object has been in scope before changes" do
        page = Page.create(:name => 'jack')

        Rails.cache.write('lorem', 'impsum', :depends_on => [Page.where(:name => 'jack')])
        Rails.cache.read('lorem').should == 'impsum'

        page.name = 'alice'
        page.save!

        Rails.cache.read('lorem').should be_nil
      end

      it "should drop if object is now in scope" do
        page = Page.create(:name => 'joe')

        Rails.cache.write('lorem', 'impsum', :depends_on => [Page.where(:name => 'jack')])
        Rails.cache.read('lorem').should == 'impsum'

        page.name = 'jack'
        page.save!

        Rails.cache.read('lorem').should be_nil
      end
    end
  end
end