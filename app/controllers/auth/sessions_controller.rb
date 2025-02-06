module Auth
  class SessionsController < ApplicationController
    # Affiche le formulaire de connexion
    def new
    end

    # Authentifie et connecte l'utilisateur avec les identifiants fournis
    def create
      if user = User.authenticate_by(email: params[:email], password: params[:password])
        login user
        redirect_to root_path, notice: t(".signed_in_successfully")
      else
        flash.now[:alert] = t(".invalid_credentials")
        render :new, status: :unprocessable_entity
      end
    end

    # Déconnecte l'utilisateur et le redirige vers la page d'accueil
    def destroy
      logout current_user
      redirect_to root_path, notice: t(".signed_out_successfully")
    end
  end
end
