# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChecklistItemsController, type: :controller do
  describe "POST #create" do
    it "creates a checklist item on own custom template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection_template_id: template.id,
               checklist_item: {
                 name: "Check foundation",
                 description: "Inspect foundation for cracks",
                 category: "Structural",
                 severity: "critical",
                 position: 1,
                 allows_photo: true,
               },
             }
      end.to change { ChecklistItem.count }.by(1)

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["success"]).to be(true)
      expect(body["item"]["name"]).to eq("Check foundation")
    end

    it "returns unprocessable entity with blank name" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      sign_in(user)

      post :create,
           params: {
             inspection_template_id: template.id,
             checklist_item: { name: "" },
           }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      expect(body["errors"]).to be_present
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
               checklist_item: { name: "Test" },
             }
      end.to raise_error(ActiveRecord::RecordNotFound)
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
               checklist_item: { name: "Test" },
             }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "PATCH #update" do
    it "updates a checklist item on own custom template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      item = create(:checklist_item, inspection_template: template, name: "Original")
      sign_in(user)

      patch :update,
            params: {
              inspection_template_id: template.id,
              id: item.id,
              checklist_item: { name: "Updated Item" },
            }

      item.reload
      expect(item.name).to eq("Updated Item")
      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["success"]).to be(true)
    end

    it "raises RecordNotFound for item on another user's custom template" do
      country = create(:country)
      user = create(:user, country: country)
      other_user = create(:user, country: country)
      other_template = create(:inspection_template, :custom, user: other_user, country: country)
      create(:checklist_item, inspection_template: other_template, name: "Original")
      sign_in(user)

      expect do
        patch :update,
              params: {
                inspection_template_id: other_template.id,
                id: 1,
                checklist_item: { name: "Hacked" },
              }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE #destroy" do
    it "destroys a checklist item on own custom template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      item = create(:checklist_item, inspection_template: template)
      sign_in(user)

      expect do
        delete :destroy,
               params: {
                 inspection_template_id: template.id,
                 id: item.id,
               }
      end.to change { ChecklistItem.count }.by(-1)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["success"]).to be(true)
    end

    it "raises RecordNotFound for item on another user's custom template" do
      country = create(:country)
      user = create(:user, country: country)
      other_user = create(:user, country: country)
      other_template = create(:inspection_template, :custom, user: other_user, country: country)
      create(:checklist_item, inspection_template: other_template)
      sign_in(user)

      expect do
        delete :destroy,
               params: {
                 inspection_template_id: other_template.id,
                 id: 1,
               }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "PATCH #reorder" do
    it "updates positions of checklist items" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      item1 = create(:checklist_item, inspection_template: template, position: 1)
      item2 = create(:checklist_item, inspection_template: template, position: 2)
      item3 = create(:checklist_item, inspection_template: template, position: 3)
      sign_in(user)

      patch :reorder,
            params: {
              inspection_template_id: template.id,
              items: [
                { id: item1.id, position: 3 },
                { id: item2.id, position: 1 },
                { id: item3.id, position: 2 },
              ],
            }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["success"]).to be(true)
      expect(item1.reload.position).to eq(3)
      expect(item2.reload.position).to eq(1)
      expect(item3.reload.position).to eq(2)
    end

    it "raises RecordNotFound for another user's custom template" do
      country = create(:country)
      user = create(:user, country: country)
      other_user = create(:user, country: country)
      other_template = create(:inspection_template, :custom, user: other_user, country: country)
      create(:checklist_item, inspection_template: other_template, position: 1)
      sign_in(user)

      expect do
        patch :reorder,
              params: {
                inspection_template_id: other_template.id,
                items: [{ id: 1, position: 1 }],
              }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      post :create, params: { inspection_template_id: 1, checklist_item: { name: "Test" } }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "subscription requirement" do
    it "redirects to billing when trial has expired" do
      country = create(:country)
      user = create(:user, country: country, trial_ends_at: 8.days.ago)
      sign_in(user)

      post :create, params: { inspection_template_id: 1, checklist_item: { name: "Test" } }

      expect(response).to redirect_to(billing_path)
      expect(flash[:alert]).to eq(I18n.t("subscription.trial_expired"))
    end
  end
end
