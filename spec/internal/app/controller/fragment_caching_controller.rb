class FragmentCachingController < ActionController::Base
  def index
  end

  def expire
    expire_fragment 'cache_entry'
  end
end