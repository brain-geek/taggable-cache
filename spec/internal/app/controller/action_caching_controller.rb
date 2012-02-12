class ActionCachingController < ActionController::Base
  caches_action :index

  def index
    Page.load_lot_of_data

    depends_on Page

    render :text => 'sdfsd'
  end

  def expire
    expire_action :action => :index
  end
end