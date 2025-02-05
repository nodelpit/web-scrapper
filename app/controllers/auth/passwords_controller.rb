module Auth
  class PasswordsController < ApplicationController
    before_action :authenticate_user!
    # Affiche le formulaire de modification du mot de passe
    def edit
    end

    # Met à jour le mot de passe de l'utilisateur connecté
    def update
      if current_user.update(passwords_params)
        redirect_to root_path, notice: "Your password has been updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
    # Définit et sécurise les paramètres pour le changement de mot de passe
    def passwords_params
      params.require(:user).permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
    end
  end
end
