# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Smoke test", type: :request do
  it "returns 200 OK on the health check endpoint" do
    get rails_health_check_path

    expect(response).to have_http_status(:ok)
  end
end
