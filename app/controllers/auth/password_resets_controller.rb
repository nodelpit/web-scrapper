module Auth
  class PasswordResetsController < ApplicationController
    before_action :set_user_by_token, only: [ :edit, :update ]

    # Affiche le formulaire de demande de réinitialisation du mot de passe
    def new
    end

    # Envoie un email de réinitialisation du mot de passe si l'utilisateur existe
    def create
      if (user = User.find_by(email: params[:email]))
        token = user.generate_token_for(:password_reset)
        Auth::PasswordMailer.with(user: user, token: token).password_reset.deliver_later
      end
      # Utilise I18n pour le message flash
      redirect_to root_path, notice: t("auth.password_resets.create.check_email")
    end

    # Affiche le formulaire de réinitialisation du mot de passe
    def edit
    end

    # Met à jour le mot de passe avec les nouvelles valeurs
    def update
      if @user.update(password_params)
        # Utilise I18n pour le message de succès
        redirect_to new_auth_session_path, notice: t("auth.password_resets.update.password_reset_success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    # Récupère l'utilisateur à partir du jeton de réinitialisation
    def set_user_by_token
      @user = User.find_by_token_for(:password_reset, params[:token])
      # Utilise I18n pour le message d'alerte
      redirect_to new_auth_password_reset_path, alert: t("auth.password_resets.set_user_by_token.invalid_token") unless @user.present?
    end

    # Définit les paramètres autorisés pour la réinitialisation
    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end
