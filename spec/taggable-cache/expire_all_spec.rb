require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TaggableCache::Store do
  it "should connect to memcached" do
    require 'dalli'
    dc = Dalli::Client.new('localhost:11211')
    dc.set('abc', 123)
    value = dc.get('abc')
  end

  it "should expire all present cache entries with depends_on" do
    Rails.cache.write 'expireme', 'value', :depends_on => Page
    Rails.cache.read('expireme').should == 'value'

    Rails.cache.expire_all

    Rails.cache.read('expireme').should be_nil
  end

  it "should not expire cache entries without depends_on" do
    Rails.cache.write 'expireme', 'value2', :depends_on => Page    
    Rails.cache.read('expireme').should == 'value2'

    Rails.cache.expire_all

    Rails.cache.read('expireme').should be_nil
  end

  it "should expire cache entries, elements for which were already deleted" do
    page = Page.new
    page.save!

    #creating second one
    Page.new.save!

    Rails.cache.write("new_page_contents", 'lorem ipsum di amet', :depends_on => page)

    page.delete # delete does not call any callbacks

    Rails.cache.read('new_page_contents').should == 'lorem ipsum di amet'

    Rails.cache.expire_all

    Rails.cache.read('new_page_contents').should be_nil
  end
end