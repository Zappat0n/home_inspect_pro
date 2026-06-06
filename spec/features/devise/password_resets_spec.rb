# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Devise Password Resets", type: :feature do
  describe "forgot password" do
    it "sends reset instructions for registered email" do
      user = create(:user)

      pg = PasswordResetPage.new
      pg.visit_forgot_page
      pg.fill_email_for_reset(user.email)
      pg.submit_forgot

      expect(pg).to have_sent_instructions_message
    end

    it "resets password with valid token" do
      user = create(:user)
      raw_token = user.send_reset_password_instructions

      pg = PasswordResetPage.new
      pg.visit_reset_page(raw_token)
      pg.fill_new_password(password: "newpassword456", password_confirmation: "newpassword456")
      pg.submit_new_password

      expect(pg).to have_password_updated_message
    end

    it "shows error with expired token" do
      user = create(:user)
      raw_token = user.send_reset_password_instructions
      user.update(reset_password_sent_at: 7.hours.ago)

      pg = PasswordResetPage.new
      pg.visit_reset_page(raw_token)
      pg.fill_new_password(password: "newpassword456", password_confirmation: "newpassword456")
      pg.submit_new_password

      expect(pg).to have_expired_token_message
    end
  end
end
