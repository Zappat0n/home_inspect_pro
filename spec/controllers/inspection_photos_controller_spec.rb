# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionPhotosController, type: :controller do
  describe "POST #create" do
    it "creates a photo and returns turbo stream" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template, allows_photo: true)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item)
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection_id: inspection.id,
               inspection_item_id: inspection_item.id,
               photo: fixture_file_upload("test_image.jpg", "image/jpeg"),
               format: :turbo_stream,
             }
      end.to change { InspectionPhoto.count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "returns error when no photo attached" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template, allows_photo: true)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item)
      sign_in(user)

      expect do
        post :create,
             params: {
               inspection_id: inspection.id,
               inspection_item_id: inspection_item.id,
               format: :turbo_stream,
             }
      end.not_to change { InspectionPhoto.count }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "raises RecordNotFound for another user's inspection" do
      country = create(:country)
      user_a = create(:user, country: country)
      user_b = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user_b, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template, allows_photo: true)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item)
      sign_in(user_a)

      expect do
        post :create,
             params: {
               inspection_id: inspection.id,
               inspection_item_id: inspection_item.id,
               photo: fixture_file_upload("test_image.jpg", "image/jpeg"),
               format: :turbo_stream,
             }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "positions photos sequentially" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template, allows_photo: true)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item)
      sign_in(user)

      post :create,
           params: {
             inspection_id: inspection.id,
             inspection_item_id: inspection_item.id,
             photo: fixture_file_upload("test_image.jpg", "image/jpeg"),
             format: :turbo_stream,
           }

      post :create,
           params: {
             inspection_id: inspection.id,
             inspection_item_id: inspection_item.id,
             photo: fixture_file_upload("test_image.jpg", "image/jpeg"),
             format: :turbo_stream,
           }

      photos = inspection.reload.inspection_photos.ordered
      expect(photos[0].position).to eq(1)
      expect(photos[1].position).to eq(2)
    end
  end

  describe "DELETE #destroy" do
    it "deletes a photo and returns turbo stream" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template, allows_photo: true)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item)
      photo = build(:inspection_photo, inspection: inspection, checklist_item: checklist_item)
      photo.photo.attach(fixture_file_upload("test_image.jpg", "image/jpeg"))
      photo.save!
      sign_in(user)

      expect do
        delete :destroy,
               params: {
                 inspection_id: inspection.id,
                 inspection_item_id: inspection_item.id,
                 id: photo.id,
                 format: :turbo_stream,
               }
      end.to change { InspectionPhoto.count }.by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "raises RecordNotFound for another user's inspection" do
      country = create(:country)
      user_a = create(:user, country: country)
      user_b = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user_b, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template, allows_photo: true)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item)
      photo = build(:inspection_photo, inspection: inspection, checklist_item: checklist_item)
      photo.photo.attach(fixture_file_upload("test_image.jpg", "image/jpeg"))
      photo.save!
      sign_in(user_a)

      expect do
        delete :destroy,
               params: {
                 inspection_id: inspection.id,
                 inspection_item_id: inspection_item.id,
                 id: photo.id,
                 format: :turbo_stream,
               }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
