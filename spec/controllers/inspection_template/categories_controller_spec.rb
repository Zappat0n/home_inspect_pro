# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionTemplate::CategoriesController, type: :controller do
  render_views

  describe "POST #create" do
    it "creates a category on own custom template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection_template_id: template.id,
               inspection_template_category: { name: "Roof" },
             },
             format: :turbo_stream
      end.to change { InspectionTemplate::Category.count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="before"')
      expect(response.body).to include('target="new_group_form"')
      expect(response.body).to include('action="replace"')
      expect(response.body).to include('target="new_group_form"')
      expect(response.body).to include("Roof")
    end

    it "returns unprocessable entity with blank name" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      sign_in(user)

      post :create,
           params: {
             inspection_template_id: template.id,
             inspection_template_category: { name: "" },
           },
           format: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="replace"')
      expect(response.body).to include('target="new_group_form"')
    end

    it "raises RecordNotFound for another user's custom template" do
      country = create(:country)
      user = create(:user, country: country)
      other_user = create(:user, country: country)
      other_template = create(:inspection_template, :custom, user: other_user, country: country)
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection_template_id: other_template.id,
               inspection_template_category: { name: "Roof" },
             }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises RecordNotFound for system template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection_template_id: template.id,
               inspection_template_category: { name: "Roof" },
             }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE #destroy" do
    it "destroys a category and returns turbo stream" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      category = create(:inspection_template_category, inspection_template: template, name: "Roof")
      sign_in(user)

      expect do
        delete :destroy, params: { inspection_template_id: template.id, id: category.id }, format: :turbo_stream
      end.to change { InspectionTemplate::Category.count }.by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="replace"')
      expect(response.body).to include('target="checklist_items"')
    end

    it "raises RecordNotFound when template belongs to another user" do
      country = create(:country)
      user_a = create(:user, country: country)
      user_b = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user_b, country: country)
      category = create(:inspection_template_category, inspection_template: template)
      sign_in(user_a)

      expect do
        delete :destroy, params: { inspection_template_id: template.id, id: category.id }, format: :turbo_stream
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "redirects to billing when trial has expired" do
      country = create(:country)
      user = create(:user, country: country, trial_ends_at: 8.days.ago)
      template = create(:inspection_template, :custom, user: user, country: country)
      category = create(:inspection_template_category, inspection_template: template)
      sign_in(user)

      delete :destroy, params: { inspection_template_id: template.id, id: category.id }

      expect(response).to redirect_to(billing_path)
      expect(flash[:alert]).to eq(I18n.t("subscription.trial_expired"))
    end
  end

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      post :create, params: { inspection_template_id: 1, inspection_template_category: { name: "Roof" } }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to sign in when not authenticated for destroy" do
      delete :destroy, params: { inspection_template_id: 1, id: 1 }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "subscription requirement" do
    it "redirects to billing when trial has expired for create" do
      country = create(:country)
      user = create(:user, country: country, trial_ends_at: 8.days.ago)
      sign_in(user)

      post :create, params: { inspection_template_id: 1, inspection_template_category: { name: "Roof" } }

      expect(response).to redirect_to(billing_path)
      expect(flash[:alert]).to eq(I18n.t("subscription.trial_expired"))
    end

    it "redirects to billing when trial has expired for destroy" do
      country = create(:country)
      user = create(:user, country: country, trial_ends_at: 8.days.ago)
      sign_in(user)

      delete :destroy, params: { inspection_template_id: 1, id: 1 }

      expect(response).to redirect_to(billing_path)
      expect(flash[:alert]).to eq(I18n.t("subscription.trial_expired"))
    end
  end
end
