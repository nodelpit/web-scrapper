require 'rails_helper'
RSpec.describe "Registrations", type: :request do
  describe "GET /registration/new" do
    # Vérifie que la page d'inscription est accessible
    it "returns a successful response" do
      get new_auth_registration_path
      expect(response).to be_successful
    end
  end

  describe "POST /registration" do
    context "avec des paramètres valides" do
      let(:valid_params) do
        {
          user: {
            email: "johndoe1777@gmail.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      # Vérifie qu'un nouvel utilisateur est créé en base
      it "creates a new user" do
        expect {
          post auth_registration_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      # Vérifie la redirection après inscription réussie
      it "redirects to root path" do
        post auth_registration_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      # Vérifie que l'utilisateur est connecté après inscription
      it "creates a user session" do
        post auth_registration_path, params: valid_params
        expect(session[:user_id]).not_to be_nil
      end
    end

    context "avec des paramètres invalides" do
      let(:invalid_params) do
        {
          user: {
            email: "johndoe1777",
            password: "password123",
            password_confirmation: "pass"
          }
        }
      end

      # Vérifie qu'aucun utilisateur n'est créé avec données invalides
      it "does not create a new user" do
        expect {
          post auth_registration_path, params: invalid_params
        }.to_not change(User, :count)
      end

      # Vérifie le statut d'erreur si validation échoue
      it "returns unprocessable entity status" do
        post auth_registration_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
