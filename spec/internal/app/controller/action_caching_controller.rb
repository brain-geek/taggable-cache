class ActionCachingController < ActionController::Base
  caches_action :index

  def index
    Page.load_lot_of_data
    render :text => 'sdfsd'
  end

  def expire
    expire_action :action => :index
  end
end