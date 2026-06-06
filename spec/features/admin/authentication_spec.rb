# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Authentication", type: :feature do
  describe "sign in" do
    it "allows admin to sign in with valid credentials and redirects to dashboard" do
      admin_user = create(:admin_user, password: "password123")

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      expect(sign_in_page).to have_signed_in_message

      dashboard_page = AdminDashboardPage.new
      expect(dashboard_page).to have_dashboard_path
    end

    it "shows error with invalid password" do
      admin_user = create(:admin_user, password: "password123")

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "wrongpassword")
      sign_in_page.submit

      expect(sign_in_page).to have_sign_in_path
      expect(sign_in_page).to have_heading
    end
  end

  describe "sign out" do
    it "allows admin to sign out and redirects to login page" do
      admin_user = create(:admin_user, password: "password123")

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit
      expect(sign_in_page).to have_signed_in_message

      dashboard_page = AdminDashboardPage.new
      dashboard_page.sign_out

      expect(sign_in_page).to have_sign_in_path
      expect(sign_in_page).to have_heading
    end
  end

  describe "access control" do
    it "redirects unauthenticated user to login page" do
      visit rails_admin.dashboard_path

      admin_login_page = AdminSignInPage.new
      expect(admin_login_page).to have_sign_in_path
      expect(admin_login_page).to have_heading
    end

    it "prevents regular user from accessing admin dashboard" do
      user = create(:user, password: "password123")

      sign_in_page = SignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(user.email, "password123")
      sign_in_page.submit
      expect(sign_in_page).to have_signed_in_message

      visit rails_admin.dashboard_path

      admin_login_page = AdminSignInPage.new
      expect(admin_login_page).to have_sign_in_path
      expect(admin_login_page).to have_heading
    end
  end
end
