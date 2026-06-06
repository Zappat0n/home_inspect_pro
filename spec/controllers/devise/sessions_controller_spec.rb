# frozen_string_literal: true

require "rails_helper"

RSpec.describe Devise::SessionsController, type: :controller do
  describe "DELETE #destroy" do
    it "redirects unauthenticated user to sign in page" do
      request.env["devise.mapping"] = Devise.mappings[:user]

      delete :destroy

      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects authenticated user to sign in page after sign out" do
      request.env["devise.mapping"] = Devise.mappings[:user]
      user = build_stubbed(:user)

      sign_in user
      delete :destroy

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
