require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'TaggableCache::Rails::Cache' do
  before :all do
    @object = TaggableCache::Store.new
    @page_object = Page.create
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

    pending "scope change" do
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