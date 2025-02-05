require 'rails_helper'

RSpec.describe Current, type: :model do
  describe "attributes" do
    # Test si on peut stocker l'utilisateur connecté
    it "can set and get user attribute" do
      user = create(:user)
      Current.user = user
      expect(Current.user).to eq(user)
    end

    # Test si l'utilisateur est bien déconnecté après reset
    it "reset user atribute between requests" do
      user = create(:user)
      Current.user = user

      Current.reset
      expect(Current.user).to be_nil
    end
  end
end
