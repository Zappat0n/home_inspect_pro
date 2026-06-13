# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionTemplate::ItemsController, type: :controller do
  describe "POST #create" do
    it "creates an item on own custom template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      category = create(:inspection_template_category, inspection_template: template, name: "Structural")
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection_template_id: template.id,
               inspection_template_item: {
                 name: "Check foundation",
                 description: "Inspect foundation for cracks",
                 inspection_template_category_id: category.id,
                 severity: "critical",
                 position: 1,
                 allows_photo: true,
               },
             },
             format: :turbo_stream
      end.to change { InspectionTemplate::Item.count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="replace"')
      expect(response.body).to include('target="checklist_items"')
    end

    it "returns unprocessable entity with blank name" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      category = create(:inspection_template_category, inspection_template: template)
      sign_in(user)

      post :create,
           params: {
             inspection_template_id: template.id,
             inspection_template_item: { name: "", inspection_template_category_id: category.id },
           },
           format: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="replace"')
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
               inspection_template_item: { name: "Test" },
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
               inspection_template_item: { name: "Test" },
             }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "PATCH #update" do
    it "updates an item on own custom template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      category = create(:inspection_template_category, inspection_template: template)
      item = create(
        :inspection_template_item,
        inspection_template: template,
        inspection_template_category: category,
        name: "Original",
      )
      sign_in(user)

      patch :update,
            params: {
              inspection_template_id: template.id,
              id: item.id,
              inspection_template_item: { name: "Updated Item" },
            },
            format: :turbo_stream

      item.reload
      expect(item.name).to eq("Updated Item")
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("inspection_template_item_#{item.id}")
    end

    it "raises RecordNotFound for item on another user's custom template" do
      country = create(:country)
      user = create(:user, country: country)
      other_user = create(:user, country: country)
      other_template = create(:inspection_template, :custom, user: other_user, country: country)
      create(:inspection_template_item, inspection_template: other_template)
      sign_in(user)

      expect do
        patch :update,
              params: {
                inspection_template_id: other_template.id,
                id: 1,
                inspection_template_item: { name: "Hacked" },
              }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE #destroy" do
    it "destroys an item on own custom template" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      category = create(:inspection_template_category, inspection_template: template)
      item = create(:inspection_template_item, inspection_template: template, inspection_template_category: category)
      sign_in(user)

      expect do
        delete :destroy,
               params: {
                 inspection_template_id: template.id,
                 id: item.id,
               },
               format: :turbo_stream
      end.to change { InspectionTemplate::Item.count }.by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="replace"')
      expect(response.body).to include('target="checklist_items"')
    end

    it "raises RecordNotFound for item on another user's custom template" do
      country = create(:country)
      user = create(:user, country: country)
      other_user = create(:user, country: country)
      other_template = create(:inspection_template, :custom, user: other_user, country: country)
      create(:inspection_template_item, inspection_template: other_template)
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
    it "updates positions of items" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, :custom, user: user, country: country)
      category = create(:inspection_template_category, inspection_template: template)
      item1 = create(
        :inspection_template_item,
        inspection_template: template,
        inspection_template_category: category,
        position: 1,
      )
      item2 = create(
        :inspection_template_item,
        inspection_template: template,
        inspection_template_category: category,
        position: 2,
      )
      item3 = create(
        :inspection_template_item,
        inspection_template: template,
        inspection_template_category: category,
        position: 3,
      )
      sign_in(user)

      patch :reorder,
            params: {
              inspection_template_id: template.id,
              items: [
                { id: item1.id, position: 3 },
                { id: item2.id, position: 1 },
                { id: item3.id, position: 2 },
              ],
            },
            format: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="replace"')
      expect(response.body).to include('target="checklist_items"')
      expect(item1.reload.position).to eq(3)
      expect(item2.reload.position).to eq(1)
      expect(item3.reload.position).to eq(2)
    end

    it "raises RecordNotFound for another user's custom template" do
      country = create(:country)
      user = create(:user, country: country)
      other_user = create(:user, country: country)
      other_template = create(:inspection_template, :custom, user: other_user, country: country)
      create(:inspection_template_item, inspection_template: other_template, position: 1)
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
      post :create, params: { inspection_template_id: 1, inspection_template_item: { name: "Test" } }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "subscription requirement" do
    it "redirects to billing when trial has expired" do
      country = create(:country)
      user = create(:user, country: country, trial_ends_at: 8.days.ago)
      sign_in(user)

      post :create, params: { inspection_template_id: 1, inspection_template_item: { name: "Test" } }

      expect(response).to redirect_to(billing_path)
      expect(flash[:alert]).to eq(I18n.t("subscription.trial_expired"))
    end
  end
end
