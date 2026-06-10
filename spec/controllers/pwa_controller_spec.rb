# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rails::PwaController, type: :controller do # rubocop:disable RSpec/SpecFilePathFormat
  render_views

  describe "GET #manifest" do
    it "returns 200 OK" do
      get :manifest, format: :json

      expect(response).to have_http_status(:ok)
    end

    it "returns JSON with correct structure" do
      get :manifest, format: :json

      json = response.parsed_body

      expect(json["name"]).to eq("HomeInspectPro")
      expect(json["display"]).to eq("standalone")
      expect(json["start_url"]).to eq("/")
      expect(json["icons"]).to be_an(Array)
      expect(json["icons"].length).to be >= 1
    end
  end

  describe "GET #service_worker" do
    it "returns 200 OK" do
      get :service_worker, format: :js

      expect(response).to have_http_status(:ok)
    end

    it "returns JavaScript with service worker logic" do
      get :service_worker, format: :js

      expect(response.body).to include("self.addEventListener")
      expect(response.body).to include("CACHE_VERSION")
    end
  end

  describe "GET #offline" do
    it "returns 200 OK" do
      get :offline

      expect(response).to have_http_status(:ok)
    end

    it "returns offline HTML page" do
      get :offline

      expect(response.body).to include("You're offline")
      expect(response.body).to include("Retry")
    end
  end
end
