# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionsController, type: :controller do
  describe "GET #index" do
    it "returns http status ok" do
      country = create(:country)
      user = create(:user, country: country)
      sign_in(user)

      get :index

      expect(response).to have_http_status(:ok)
    end

    it "returns http status ok for user with inspections" do
      country = create(:country)
      user = create(:user, country: country)
      other_user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      create(
        :inspection,
        user: user,
        inspection_template: template,
        property_address: "Newer Address",
        created_at: 1.day.ago,
      )
      create(
        :inspection,
        user: user,
        inspection_template: template,
        property_address: "Older Address",
        created_at: 2.days.ago,
      )
      create(
        :inspection,
        user: other_user,
        inspection_template: template,
        property_address: "Other User Address",
      )
      sign_in(user)

      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns http status ok" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template)
      sign_in(user)

      get :show, params: { id: inspection.id }

      expect(response).to have_http_status(:ok)
    end

    it "raises RecordNotFound for another user's inspection" do
      country = create(:country)
      user_a = create(:user, country: country)
      user_b = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user_b, inspection_template: template)
      sign_in(user_a)

      expect do
        get :show, params: { id: inspection.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    it "returns http status ok" do
      country = create(:country)
      user = create(:user, country: country)
      sign_in(user)

      get :new

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    it "creates a new inspection scoped to current_user" do
      country = create(:country)
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true)
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection: {
                 property_address: "456 Oak St",
                 client_name: "Jane Doe",
                 client_email: "jane@example.com",
               },
             }
      end.to change { Inspection.count }.by(1)

      expect(Inspection.last.user).to eq(user)
      expect(response).to redirect_to(inspection_path(Inspection.last))
    end

    it "falls back to US template when user's country has no published template" do
      country_no_templates = create(:country, code: "XX", name: "No Templates")
      user = create(:user, country: country_no_templates)
      us_country = create(:country, code: "US", name: "United States")
      create(
        :inspection_template,
        country: us_country,
        published: true,
        name: "US Template",
      )
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection: {
                 property_address: "456 Oak St",
                 client_name: "Jane Doe",
                 client_email: "jane@example.com",
               },
             }
      end.to change { Inspection.count }.by(1)

      expect(Inspection.last.inspection_template.country.code).to eq("US")
      expect(response).to redirect_to(inspection_path(Inspection.last))
    end

    it "re-renders new with unprocessable status when params invalid" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true)
      sign_in(user)

      post :create, params: { inspection: { property_address: "", client_name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH #complete" do
    it "completes a draft inspection" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template)
      sign_in(user)

      patch :complete, params: { id: inspection.id }

      inspection.reload
      expect(inspection).to be_completed
      expect(inspection.completed_at).not_to be_nil
      expect(response).to redirect_to(inspection_path(inspection))
    end

    it "redirects already completed inspection" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(
        :inspection,
        user: user,
        inspection_template: template,
        status: :completed,
      )
      sign_in(user)

      patch :complete, params: { id: inspection.id }

      expect(response).to redirect_to(inspection_path(inspection))
      expect(flash[:alert]).to be_present
    end

    it "does not allow access to another user's inspection" do
      country = create(:country)
      user_a = create(:user, country: country)
      user_b = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user_b, inspection_template: template)
      sign_in(user_a)

      expect do
        patch :complete, params: { id: inspection.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #report" do
    it "generates a PDF and redirects to the pdf_url" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(
        :inspection,
        user: user,
        inspection_template: template,
        pdf_url: "http://example.com/report.pdf",
      )
      sign_in(user)

      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      allow(Grover).to receive(:new).and_return(grover_double)

      service_double = instance_double(PdfReportService, call: nil)
      allow(PdfReportService).to receive(:new).and_return(service_double)

      get :report, params: { id: inspection.id }

      expect(response).to redirect_to("http://example.com/report.pdf")
    end

    it "raises RecordNotFound for another user's inspection" do
      country = create(:country)
      user_a = create(:user, country: country)
      user_b = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user_b, inspection_template: template)
      sign_in(user_a)

      expect do
        get :report, params: { id: inspection.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
