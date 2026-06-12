# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionTemplatesController, type: :controller do
  describe "GET #index" do
    it "returns http status ok" do
      country = create(:country)
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true)
      sign_in(user)

      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "returns http status ok" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true)
      sign_in(user)

      get :show, params: { id: template.id }

      expect(response).to have_http_status(:ok)
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
    it "creates a new custom template scoped to current_user" do
      country = create(:country)
      user = create(:user, country: country)
      sign_in(user)

      expect do
        post :create, params: { inspection_template: { name: "My Custom Template" } }
      end.to change { InspectionTemplate.count }.by(1)

      template = InspectionTemplate.last
      expect(template.user).to eq(user)
      expect(template.template_type).to eq("custom")
      expect(template.name).to eq("My Custom Template")
      expect(response).to redirect_to(inspection_template_path(template))
    end

    it "re-renders new with unprocessable status when name is blank" do
      country = create(:country)
      user = create(:user, country: country)
      sign_in(user)

      post :create, params: { inspection_template: { name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST #duplicate" do
    it "duplicates a published template and redirects to edit" do
      country = create(:country)
      user = create(:user, country: country)
      source = create(:inspection_template, country: country, published: true)
      sign_in(user)

      expect do
        post :duplicate, params: { id: source.id }
      end.to change { InspectionTemplate.count }.by(1)

      duplicated = InspectionTemplate.last
      expect(duplicated.name).to eq("Copy of #{source.name}")
      expect(duplicated.user).to eq(user)
      expect(duplicated.template_type).to eq("custom")
      expect(duplicated).not_to be_published
      expect(response).to redirect_to(edit_inspection_template_path(duplicated))
    end

    it "redirects with alert when source template not found" do
      country = create(:country)
      user = create(:user, country: country)
      sign_in(user)

      post :duplicate, params: { id: -1 }

      expect(response).to redirect_to(inspection_templates_path)
      expect(flash[:alert]).to eq(I18n.t("inspection_templates.duplicate.not_found"))
    end
  end

  describe "GET #edit" do
    it "returns http status ok for own custom template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      sign_in(user)

      get :edit, params: { id: template.id }

      expect(response).to have_http_status(:ok)
    end

    it "redirects with alert for system template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      sign_in(user)

      get :edit, params: { id: template.id }

      expect(response).to redirect_to(inspection_templates_path)
      expect(flash[:alert]).to eq(I18n.t("inspection_templates.not_authorized"))
    end
  end

  describe "PATCH #update" do
    it "updates own custom template name and redirects" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country, name: "Original")
      sign_in(user)

      patch :update, params: { id: template.id, inspection_template: { name: "Updated Name" } }

      template.reload
      expect(template.name).to eq("Updated Name")
      expect(response).to redirect_to(inspection_template_path(template))
    end

    it "re-renders edit with unprocessable status when name is blank" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      sign_in(user)

      patch :update, params: { id: template.id, inspection_template: { name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "redirects with alert for system template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      sign_in(user)

      patch :update, params: { id: template.id, inspection_template: { name: "Hacked" } }

      expect(response).to redirect_to(inspection_templates_path)
      expect(flash[:alert]).to eq(I18n.t("inspection_templates.not_authorized"))
    end
  end

  describe "DELETE #destroy" do
    it "destroys own custom template with no inspections and redirects" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      sign_in(user)

      expect do
        delete :destroy, params: { id: template.id }
      end.to change { InspectionTemplate.count }.by(-1)

      expect(response).to redirect_to(inspection_templates_path)
      expect(flash[:notice]).to eq(I18n.t("inspection_templates.destroy.success"))
    end

    it "does not destroy template that has inspections and redirects with alert" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      create(:inspection, user: user, inspection_template: template)
      sign_in(user)

      expect do
        delete :destroy, params: { id: template.id }
      end.not_to change { InspectionTemplate.count }

      expect(response).to redirect_to(inspection_templates_path)
      expect(flash[:alert]).to eq(
        I18n.t("inspection_templates.destroy.in_use", count: template.inspections.count),
      )
    end

    it "redirects with alert for system template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      sign_in(user)

      delete :destroy, params: { id: template.id }

      expect(response).to redirect_to(inspection_templates_path)
      expect(flash[:alert]).to eq(I18n.t("inspection_templates.not_authorized"))
    end
  end

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      get :index

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "subscription requirement" do
    it "redirects to billing when trial has expired" do
      country = create(:country)
      user = create(:user, country: country, trial_ends_at: 8.days.ago)
      sign_in(user)

      post :create, params: { inspection_template: { name: "My Template" } }

      expect(response).to redirect_to(billing_path)
      expect(flash[:alert]).to eq(I18n.t("subscription.trial_expired"))
    end
  end
end
