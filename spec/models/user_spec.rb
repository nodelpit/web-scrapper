require 'rails_helper'

RSpec.describe User, type: :model do
 let(:user) { build(:user) }

 describe "validations" do
   # Vérifie que l'utilisateur est valide avec tous les champs requis
   it "is valid with valid attributes" do
     expect(user).to be_valid
   end

   # Vérifie que l'email est obligatoire
   it "is not valid without an email" do
     user.email = nil
     expect(user).not_to be_valid
   end

   # Vérifie que l'email doit avoir un format valide
   it "is not valid with invalid email format" do
     user.email = "johndoe1777"
     expect(user).not_to be_valid
   end

   # Vérifie que l'email doit être unique
   it "is not valid with duplicate email" do
     create(:user, email: "johndoe1777@gmail.com")
     duplicate_user = build(:user, email: "johndoe1777@gmail.com")
     expect(duplicate_user).not_to be_valid
   end
 end

 describe "roles" do
  # Vérifie que le rôle par défaut est 'user'
  it "has user role by default" do
    expect(user.role).to eq("user")
  end

  # Vérifie la création d'un admin
  it "can be an admin" do
    admin = build(:user, :admin)
    expect(admin.role).to eq("admin")
  end

  # Vérifie la méthode admin?
  it "can check if user is admin" do
    regular_user = build(:user)
    admin_user = build(:user, :admin)

    expect(regular_user.admin?).to be false
    expect(admin_user.admin?).to be true
  end
 end

  # Nouveau contexte pour la protection du rôle admin
  describe "admin role protection" do
    before do
      ENV["ADMIN_EMAIL"] = "admin@example.com"
    end

    it "prevents changing role of main admin" do
      admin = create(:user, email: ENV["ADMIN_EMAIL"], role: :admin)
      expect(admin.update(role: :user)).to be false
      expect(admin.errors[:role]).to include(I18n.t("activerecord.errors.models.user.attributes.role.admin_change"))
    end

    it "allows changing role of non-admin users" do
      regular_user = create(:user, email: "user@example.com", role: :user)
      expect(regular_user.update(role: :admin)).to be true
    end

    it "allows changing role of other admin users" do
      other_admin = create(:user, email: "other_admin@example.com", role: :admin)
      expect(other_admin.update(role: :user)).to be true
    end

    after do
      ENV["ADMIN_EMAIL"] = nil
    end
   end

 describe "email normalization" do
   # Vérifie que l'email est converti en minuscules
   it "converts email to lowercase before saving" do
     user.email = "JOHNDOE1777@GMAIL.COM"
     user.save
     expect(user.email).to eq("johndoe1777@gmail.com")
   end

   # Vérifie que les espaces sont supprimés de l'email
   it "removes whitespace from email before saving" do
     user.email = " johndoe1777@gmail.com "
     user.save
     expect(user.email).to eq("johndoe1777@gmail.com")
   end
 end

 describe "password reset token" do
   # Vérifie la génération du token pour réinitialiser le mot de passe
   it "generates token for password reset" do
     user.save
     expect(user.generate_token_for(:password_reset)).to be_present
   end
 end

 describe "remember me token" do
   # Vérifie la génération du token pour remember me
   it "can generate remember me token" do
     user.save
     token = user.generate_token_for(:remember_me)
     expect(token).to be_present
   end

   # Vérifie que le token reste le même si rien ne change
   it "generates consistent tokens for same data" do
    user.save
    token1 = user.generate_token_for(:remember_me)
    # Simule un autre appel de génération de token pour le même utilisateur
    token2 = user.generate_token_for(:remember_me)
    expect(token1).to eq(token2) # Les tokens doivent être identiques car les données sont les mêmes
  end


   # Vérifie que les tokens sont différents entre utilisateurs
   it "generates different tokens for different users" do
     first_user = create(:user, email: "user1@example.com")
     second_user = create(:user, email: "user2@example.com")
     token1 = first_user.generate_token_for(:remember_me)
     token2 = second_user.generate_token_for(:remember_me)
     expect(token1).not_to eq(token2)
   end

   # Vérifie que le token change quand le mot de passe change
   it "generates different token when password changes" do
     user.save
     old_token = user.generate_token_for(:remember_me)
     user.update(password: "new_password")
     new_token = user.generate_token_for(:remember_me)
     expect(new_token).not_to eq(old_token)
   end
 end
end
