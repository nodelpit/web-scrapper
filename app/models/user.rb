class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  normalizes :email, with: ->(email) { email.strip.downcase }

  def self.human_attribute_name(attribute, *args)
    case attribute.to_sym
    when :password_confirmation, :password_challenge
      ""
    else
      super
    end
  end

  # Pour la réinitialisation du mot de passe
  generates_token_for :password_reset do
    password_salt&.last(10)
  end

  # Pour la confirmation d'email
  generates_token_for :email_confirmation, expires_in: 24.hours do
    email
  end

  # Pour la fonctionnalité "Se souvenir de moi"
  generates_token_for :remember_me, expires_in: 2.weeks do
    # On utilise une combinaison de l'id et du password_salt pour plus de sécurité
    "#{id}#{password_salt&.last(10)}"
  end

  # Pour éviter les problèmes de sécurité, on invalide le token si le mot de passe change
  after_save :invalidate_remember_token, if: :saved_change_to_password_digest?

  private

  def invalidate_remember_token
    remember_token.token = nil if remember_token
  end
end
