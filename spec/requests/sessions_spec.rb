require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /session/new" do
    # Vérifie que la page de connexion est accessible
    it "returns a successful response" do
      get new_auth_session_path
      expect(response).to be_successful
    end
  end

  describe "POST /session" do
    # On crée un utilisateur pour tester la connexion
    let(:user) { create(:user) }

    context "avec des paramètres valides" do
      let(:password) { "password123" }
      let(:valid_params) do
        { email: user.email, password: password }
      end

      # Vérifie la redirection après connexion réussie
      it "logs in the user" do
        post auth_session_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      # Vérifie le message de succès
      it "sets success notice" do
        post auth_session_path, params: valid_params
        expect(flash[:notice]).to eq("Connexion réussie")
      end
    end

    context "avec des paramètres invalides" do
      let(:invalid_params) do
        { email: "wrong@email.com", password: "wrongpassword" }
      end

      # Vérifie que le formulaire est réaffiché en cas d'échec
      it "renders the new template" do
        post auth_session_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      # Vérifie le message d'erreur
      it "sets error alert" do
        post auth_session_path, params: invalid_params
        expect(flash[:alert]).to eq("Email ou mot de passe incorrect")
      end
    end
  end

  describe "DELETE /session" do
    let(:user) { create(:user) }

    # On connecte l'utilisateur avant les tests de déconnexion
    before do
      post auth_session_path, params: { email: user.email, password: "password123" }
    end

    # Vérifie la redirection après déconnexion
    it "logs out the user" do
      delete auth_session_path
      expect(response).to redirect_to(root_path)
    end

    # Vérifie le message de déconnexion
    it "sets success notice" do
      delete auth_session_path
      expect(flash[:notice]).to eq("Vous avez été déconnecté avec succès")
    end
  end
end
