require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  describe "GET /admin" do
    # Test pour un utilisateur non connecté
    context "when not logged in" do
      it "redirects to root path" do
        get admin_root_path
        expect(response).to redirect_to root_path
      end
    end

    # Test pour un utilisateur connecté sans droits d'administration
    context "when logged in as normal user" do
      let(:user) { create(:user) }

      before do
        # Connexion d'un utilisateur standard
        post auth_session_path, params: { email: user.email, password: user.password }
      end

      it "redirects to root path" do
        get admin_root_path
        expect(response).to redirect_to root_path
      end
    end

    # Test pour un administrateur connecté avec le bon email
    context "when logged in as admin" do
      let(:admin) { create(:user, role: :admin) }

      # Créer quelques utilisateurs pour les tests de comptage
      before do
        # Création de plusieurs utilisateurs avec différents rôles
        create_list(:user, 3, role: :user)
        create_list(:user, 3, role: :admin)

        # Configuration de l'email admin dans l'environnement
        ENV["ADMIN_EMAIL"] = admin.email
        post auth_session_path, params: { email: admin.email, password: admin.password }
      end

      it "assigns total number of users" do
        get admin_root_path
        expect(controller.instance_variable_get(:@total_users)).to eq(7)
      end

      it "assigns users by role" do
        get admin_root_path
        expect(controller.instance_variable_get(:@users_by_role)).to eq({
          "user" => 3,
          "admin" => 4
        })
      end
    end

    # Test pour un administrateur connecté mais avec un email incorrect
    context "when logged in as admin but wrong email" do
      let(:admin) { create(:user, :admin, email: "wrong@email.com") }

      before do
        # Configuration d'un email différent de celui de l'admin connecté
        ENV["ADMIN_EMAIL"] = "correct@email.com"
        post auth_session_path, params: { email: admin.email, password: admin.password }
      end

      it "redirects to root path" do
        get admin_root_path
        expect(response).to redirect_to root_path
      end
    end
  end
end
