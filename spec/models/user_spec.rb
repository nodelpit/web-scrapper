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
