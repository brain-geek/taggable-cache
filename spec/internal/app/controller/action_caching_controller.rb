class ActionCachingController < ActionController::Base
  caches_action :index

  caches_action :cp, :cache_path => Proc.new { {'key' => 'value', 2 => 56} }

  def index
    Page.load_lot_of_data

    depends_on Page

    render :text => 'none'
  end

  def cp
    Page.load_lot_of_data

    depends_on Page

    render :text => 'none'
  end
end