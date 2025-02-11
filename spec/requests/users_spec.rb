require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user_to_manage) { create(:user, email: "user@example.com") }
  let(:admin_user) {
    create(:user,
      email: "admin@example.com",
      password: "password",
      password_confirmation: "password",
      role: "admin"
    )
  }

  shared_context "admin logged in" do
    before do
      ENV["ADMIN_EMAIL"] = admin_user.email
      post auth_session_path, params: { email: admin_user.email, password: "password" }
    end
  end

  describe "GET #admin/users" do
    context "when logged in as admin" do
      include_context "admin logged in"
      before { create_list(:user, 3) }

      it "returns a successful response with correct user count" do
        get admin_users_path
        expect(response).to have_http_status(:success)
        expect(controller.instance_variable_get(:@users).count).to eq(4)
      end
    end

    context "with search parameter" do
      include_context "admin logged in"
      before { create(:user, email: "searchuser@example.com") }

      it "filters users by email" do
        get admin_users_path, params: { search: "searchuser" }
        users = controller.instance_variable_get(:@users)
        expect(users.count).to eq(1)
        expect(users.first.email).to eq("searchuser@example.com")
      end
    end
  end

  describe "GET #edit" do
    context "when logged in as admin" do
      include_context "admin logged in"

      it "returns a successful response with correct user" do
        get edit_admin_user_path(user_to_manage)
        expect(response).to have_http_status(:success)
        expect(controller.instance_variable_get(:@user)).to eq(user_to_manage)
      end
    end

    context "when not logged in" do
      it "redirects to root path" do
        get edit_admin_user_path(user_to_manage)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH #update" do
    context "when logged in as admin" do
      include_context "admin logged in"

      it "successfully updates user role" do
        patch admin_user_path(user_to_manage), params: { user: { role: :admin } }
        user_to_manage.reload
        expect(user_to_manage.role).to eq('admin')
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to be_present
      end

      it "handles invalid updates" do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        patch admin_user_path(user_to_manage), params: { user: { role: :admin } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when not logged in" do
      it "redirects to root path" do
        patch admin_user_path(user_to_manage), params: { user: { role: :admin } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when logged in as admin" do
      include_context "admin logged in"

      it "prevents deleting admin user" do
        delete admin_user_path(admin_user)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:alert]).to be_present
        expect(User.exists?(admin_user.id)).to be_truthy
      end

      it "successfully deletes regular user" do
        delete admin_user_path(user_to_manage)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to be_present
        expect(User.exists?(user_to_manage.id)).to be_falsey
      end
    end

    context "when not logged in" do
      it "redirects to root path" do
        delete admin_user_path(user_to_manage)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
