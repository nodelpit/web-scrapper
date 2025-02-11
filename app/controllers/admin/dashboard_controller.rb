module Admin
  class DashboardController < Admin::BaseController
    def index
      @total_users = User.count
      @users_by_role = User.group(:role).count
    end
  end
end
