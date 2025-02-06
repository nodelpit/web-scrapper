require 'rails_helper'

RSpec.describe "PasswordResets", type: :request do
  # On utilise create car on teste des requêtes HTTP qui nécessitent
  # un vrai utilisateur en base
  let(:user) { create(:user) }

  describe "GET /password_reset/new" do
    # Vérifie que la page de demande de reset est accessible
    it "returns a successful response" do
      get new_auth_password_reset_path
      expect(response).to be_successful
    end
  end

  describe "POST /password_reset" do
    context "avec un email existant" do
      # Vérifie la redirection après demande de reset
      it "redirect to root path" do
        post auth_password_reset_path, params: { email: user.email }
        expect(response).to redirect_to root_path
      end

      # Vérifie le message de confirmation
      it "sets a success notice" do
        post auth_password_reset_path, params: { email: user.email }
        expect(flash[:notice]).to eq(I18n.t('auth.password_resets.create.check_email'))
      end

      # Vérifie que l'email de reset est envoyé
      it "sends a password reset email" do
        expect {
          post auth_password_reset_path, params: { email: user.email }
        }.to have_enqueued_mail(Auth::PasswordMailer, :password_reset)
      end
    end

    context "avec un email inexistant" do
      # Vérifie la redirection même avec email invalide (sécurité)
      it "redirects to root path" do
        post auth_password_reset_path, params: { email: "nonexistent@example.com" }
        expect(response).to redirect_to root_path
      end

      # Vérifie qu'aucun email n'est envoyé
      it "does not send an email" do
        expect {
          post auth_password_reset_path, params: { email: "nonexistent@example.com" }
        }.not_to have_enqueued_mail(Auth::PasswordMailer, :password_reset)
      end
    end
  end

  describe "GET /password_reset/edit" do
    context "avec un token valide" do
      let(:token) { user.generate_token_for(:password_reset) }

      # Vérifie l'accès au formulaire de reset
      it "returns successful response" do
        get edit_auth_password_reset_path(token: token)
        expect(response).to be_successful
      end
    end

    context "avec un token invalide" do
      # Vérifie la redirection si token invalide
      it "returns to new password reset path" do
        get edit_auth_password_reset_path(token: "invalid_token")
        expect(response).to redirect_to(new_auth_password_reset_path)
        expect(flash[:alert]).to eq(I18n.t('auth.password_resets.set_user_by_token.invalid_token'))
      end
    end
  end

  describe "PATCH /password_reset" do
    let(:token) { user.generate_token_for(:password_reset) }

    context "avec des paramètres valides" do
      let(:valid_params) do
        {
          token: token,
          user: { password: "newpassword123", password_confirmation: "newpassword123" }
        }
      end

      # Vérifie la redirection vers login après reset réussi
      it "redirects to new session path" do
        patch auth_password_reset_path, params: valid_params
        expect(response).to redirect_to new_auth_session_path
      end

      # Vérifie le message de succès
      it "sets a success notice" do
        patch auth_password_reset_path, params: valid_params
        expect(flash[:notice]).to eq(I18n.t('auth.password_resets.update.password_reset_success'))
      end

      # Vérifie que le mot de passe est bien mis à jour
      it "updates the user's password" do
        patch auth_password_reset_path, params: valid_params
        user.reload
        expect(user.authenticate("newpassword123")).to be_truthy
      end
    end

    context "avec des paramètres invalides" do
      let(:invalid_params) do
        {
          token: token,
          user: { password: "newpassword123", password_confirmation: "newpassword" }
        }
      end

      # Vérifie le statut d'erreur si validation échoue
      it "renders the edit template" do
        patch auth_password_reset_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      # Vérifie que le mot de passe reste inchangé
      it "does not update the password" do
        original_password_digest = user.password_digest
        patch auth_password_reset_path, params: invalid_params
        user.reload
        expect(user.password_digest).to eq(original_password_digest)
      end
    end
  end
end
