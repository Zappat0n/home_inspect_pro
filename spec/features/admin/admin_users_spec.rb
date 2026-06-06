# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AdminUser CRUD", type: :feature do
  describe "managing admin users via RailsAdmin" do
    it "lists admin users on the index page" do
      admin_user = create(:admin_user)
      listed_user = create(:admin_user, email: "listed@example.com")

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      expect(sign_in_page).to have_signed_in_message

      index_page = AdminUserListPage.new
      index_page.visit_page

      expect(index_page).to have_page_title
      expect(index_page).to have_admin_user(listed_user)
    end

    it "creates a new admin user" do
      admin_user = create(:admin_user)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      expect(sign_in_page).to have_signed_in_message

      form_page = NewAdminUserPage.new
      form_page.visit_page
      form_page.fill_in_with("newadmin@example.com", "password123", "password123")
      form_page.submit

      expect(AdminUser.find_by(email: "newadmin@example.com")).to be_present
      expect(form_page).to have_success_message
    end

    it "edits an existing admin user" do
      admin_user = create(:admin_user)
      target_user = create(:admin_user, email: "target@example.com")

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      expect(sign_in_page).to have_signed_in_message

      index_page = AdminUserListPage.new
      index_page.visit_page
      index_page.click_edit(target_user)

      form_page = NewAdminUserPage.new
      form_page.fill_in_with("updated@example.com", "newpass123", "newpass123")
      form_page.submit

      expect(form_page).to have_update_message
      expect(target_user.reload.email).to eq("updated@example.com")
    end

    it "deletes an admin user" do
      admin_user = create(:admin_user)
      target_user = create(:admin_user, email: "delete@example.com")

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      expect(sign_in_page).to have_signed_in_message

      index_page = AdminUserListPage.new
      index_page.visit_page
      expect(index_page).to have_admin_user(target_user)

      expect do
        index_page.click_delete(target_user)
        index_page.confirm_delete
      end.to change { AdminUser.count }.by(-1)

      expect(index_page).to have_success_message
      expect(index_page).to have_no_admin_user(target_user)
    end

    it "shows admin user details" do
      admin_user = create(:admin_user)
      target_user = create(:admin_user, email: "show@example.com")

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      expect(sign_in_page).to have_signed_in_message

      index_page = AdminUserListPage.new
      index_page.visit_page
      expect(index_page).to have_admin_user(target_user)

      index_page.click_show(target_user)

      expect(index_page).to have_details_for(target_user)
    end
  end
end
