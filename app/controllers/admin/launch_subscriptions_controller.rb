module Admin
  class LaunchSubscriptionsController < ApplicationController
    layout "admin"
    before_action :require_admin

    def index
      @count = LaunchSubscription.count
      @page = [ params[:page].to_i, 1 ].max
      @subscriptions = LaunchSubscription.order(created_at: :desc, id: :desc).limit(50).offset((@page - 1) * 50)
    end
  end
end
