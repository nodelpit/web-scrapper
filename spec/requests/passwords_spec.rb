require 'rails_helper'
RSpec.describe "Passwords", type: :request do
  # On crée un vrai utilisateur car on teste l'authentification
  let(:user) { create(:user) }
  context "quand l'utilisateur n'est pas connecté" do
    # Vérifie qu'on ne peut pas accéder au formulaire sans être connecté
    it "redirects to root path for edit action" do
      get edit_auth_password_path
      expect(response).to redirect_to(root_path)
    end
    # Vérifie qu'on ne peut pas modifier le mot de passe sans être connecté
    it "redirects to root path for update action" do
      patch auth_password_path, params: { user: { password: "newpass" } }
      expect(response).to redirect_to(root_path)
    end
  end
  context "quand l'utilisateur est connecté" do
    # On connecte l'utilisateur avant chaque test
    before do
      post auth_session_path, params: { email: user.email, password: "password123" }
    end
    describe "GET /password/edit" do
      # Vérifie l'accès au formulaire de changement de mot de passe
      it "returns a successful response" do
        get edit_auth_password_path
        expect(response).to be_successful
      end
    end
    describe "PATCH /password" do
      context "avec des paramètres valides" do
        let(:valid_params) do
          {
            user: {
              password: "newpassword123",
              password_confirmation: "newpassword123",
              password_challenge: "password123" # Mot de passe actuel
            }
          }
        end
        # Vérifie la redirection après changement réussi
        it "updates the password" do
          patch auth_password_path, params: valid_params
          expect(response).to redirect_to root_path
        end
        # Vérifie le message de succès
        it "sets success notice" do
          patch auth_password_path, params: valid_params
          expect(flash[:notice]).to eq("Your password has been updated successfully.")
        end
      end
      context "avec des paramètres invalides" do
        let(:invalid_params) do
          {
            user: {
              password: "new", # Trop court
              password_confirmation: "different", # Ne correspond pas
              password_challenge: "" # Vide
            }
          }
        end
        # Vérifie que le formulaire est ré-affiché en cas d'erreur
        it "renders the edit template" do
          patch auth_password_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
