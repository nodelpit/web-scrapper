require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  # On crée un vrai utilisateur car on teste l'authentification avec la session
  let(:user) { create(:user) }

  describe '#authenticate_user_from_session' do
    # Vérifie qu'on retrouve l'utilisateur avec son ID en session
    it 'returns user when valid user_id is in session' do
      session[:user_id] = user.id
      expect(controller.send(:authenticate_user_from_session)).to eq(user)
    end

    # Vérifie qu'on gère bien le cas d'un ID invalide
    it 'returns nil when invalid user_id is in session' do
      session[:user_id] = 9999
      expect(controller.send(:authenticate_user_from_session)).to be_nil
    end
  end

  describe '#current_user' do
    # Vérifie que current_user est nil si pas d'authentification
    it 'returns nil when no user is authenticated' do
      allow(controller).to receive(:authenticate_user_from_session).and_return(nil)
      expect(controller.send(:current_user)).to be_nil
    end

    # Vérifie que current_user renvoie l'utilisateur authentifié
    it 'returns the authenticated user' do
      allow(controller).to receive(:authenticate_user_from_session).and_return(user)
      expect(controller.send(:current_user)).to eq(user)
    end
  end

  describe '#user_signed_in?' do
    # Vérifie que user_signed_in? est false sans utilisateur
    it 'returns false when current_user is nil' do
      allow(controller).to receive(:current_user).and_return(nil)
      expect(controller.send(:user_signed_in?)).to be false
    end

    # Vérifie que user_signed_in? est true avec un utilisateur
    it 'returns true when current_user is present' do
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller.send(:user_signed_in?)).to be true
    end
  end

  describe '#authenticate_user!' do
  it 'redirects to root path when user is not signed in' do
    # Forcer explicitement la locale
    I18n.locale = :fr

    # Vérifier la traduction
    translation = I18n.t('auth.authentication.login_required')
    puts "Translation: #{translation}"

    # Simule un utilisateur non connecté
    allow(controller).to receive(:user_signed_in?).and_return(false)

    # Vérifie la redirection avec la traduction
    expect(controller).to receive(:redirect_to).with(
      root_path,
      alert: translation
    )

    # Déclenche la méthode d'authentification
    controller.send(:authenticate_user!)
  end

  # Vérifie qu'on ne redirige pas si connecté
  it 'does nothing when user is signed in' do
    # Simule un utilisateur connecté
    allow(controller).to receive(:user_signed_in?).and_return(true)

    # Vérifie qu'aucune redirection n'est effectuée
    expect(controller).not_to receive(:redirect_to)

    # Déclenche la méthode d'authentification
    controller.send(:authenticate_user!)
  end
end

  describe '#login' do
    # Vérifie que login stocke l'ID en session
    it 'sets the user_id in the session' do
      controller.send(:login, user)
      expect(session[:user_id]).to eq(user.id)
    end

    # Vérifie que login définit Current.user
    it 'sets Current.user' do
      controller.send(:login, user)
      expect(Current.user).to eq(user)
    end
  end

  describe '#logout' do
    before do
      session[:user_id] = user.id
      Current.user = user
    end

    # Vérifie que logout nettoie la session
    it 'removes the user_id from the session' do
      controller.send(:logout, user)
      expect(session[:user_id]).to be_nil
    end

    # Vérifie que logout nettoie Current.user
    it 'sets Current.user to nil' do
      controller.send(:logout, user)
      expect(Current.user).to be_nil
    end
  end
end
