module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    layout "admin/layout"

    private

    def authenticate_admin!
      unless current_user&.email == ENV["ADMIN_EMAIL"] && current_user&.admin?
        redirect_to root_path, alert: t("admin.base.unauthorized'")
      end
    end
  end
end
