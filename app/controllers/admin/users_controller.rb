module Admin
  class UsersController < Admin::BaseController
    def index
      @users = if params[:search].present?
        User.where("email LIKE ?", "%#{params[:search]}%")
      else
        User.all
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to admin_users_path, notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      if @user.email == ENV["ADMIN_EMAIL"]
        redirect_to admin_users_path, alert: t(".admin_error")
      else
        @user.destroy
        redirect_to admin_users_path, notice: t(".success")
      end
    end

    private

    def user_params
      permitted_params = [ :email, :password, :password_confirmation ]
      permitted_params << :role if current_user.admin?
      params.require(:user).permit(permitted_params)
    end
  end
end
