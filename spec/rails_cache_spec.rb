require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe 'TaggableCache::Rails::Cache' do
  before :all do
    @object = TaggableCache::Store.new
    Redis.new.flushall
    @page_object = Page.create    
  end

  describe "taggable hooked on Rails.cache.write" do
    it "adds key to store" do
      Rails.cache.write 'key', 'value', :depends_on => [@page_object]

      @object.get(@page_object).should == ['key']
    end
  end

  describe "taggable hooked as observer" do
    it "detects object change" do
      Rails.cache.write 'key', 'value', :depends_on => [@page_object]

      Rails.cache.read('key').should == 'value'

      #save should trigger deleting depending cache entries
      @page_object.name = @page_object.name.to_s + '1'
      @page_object.save!

      Rails.cache.read('key').should be_nil
    end

    it "detects model change" do
      Rails.cache.write 'lorem', 'impsum', :depends_on => [Page]

      Rails.cache.read('lorem').should == 'impsum'

      Page.create

      Rails.cache.read('lorem').should be_nil
    end

    it "does simple writes" do
      Rails.cache.write 'ipsum', 'lorem'
      Rails.cache.read('ipsum').should == 'lorem'
    end
  end
end