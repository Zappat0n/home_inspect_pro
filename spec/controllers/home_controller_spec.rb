# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomeController, type: :controller do
  render_views

  describe "GET #index" do
    it "returns 200 OK without authentication" do
      get :index

      expect(response).to have_http_status(:ok)
    end

    it "renders the home page" do
      get :index

      expect(response.body).to include(I18n.t("landing.hero.headline"))
    end
  end
end
