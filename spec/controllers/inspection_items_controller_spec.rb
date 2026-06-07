# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionItemsController, type: :controller do
  render_views

  describe "PATCH #update" do
    it "updates inspection item status to ok" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item, status: :na)
      sign_in(user)

      patch :update,
            params: {
              inspection_id: inspection.id,
              id: inspection_item.id,
              inspection_item: {
                status: "ok",
                comment: nil,
              },
              format: :turbo_stream,
            }

      inspection_item.reload
      expect(inspection_item.status).to eq("ok")
      expect(response).to have_http_status(:ok)
    end

    it "updates inspection item with comment" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item, status: :ok)
      sign_in(user)

      patch :update,
            params: {
              inspection_id: inspection.id,
              id: inspection_item.id,
              inspection_item: {
                status: "defect",
                comment: "Found a crack",
              },
              format: :turbo_stream,
            }

      inspection_item.reload
      expect(inspection_item.status).to eq("defect")
      expect(inspection_item.comment).to eq("Found a crack")
      expect(response).to have_http_status(:ok)
    end

    it "redirects with alert when inspection is completed" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user, inspection_template: template, status: :completed)
      checklist_item = create(:checklist_item, inspection_template: template)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item, status: :ok)
      sign_in(user)

      patch :update,
            params: {
              inspection_id: inspection.id,
              id: inspection_item.id,
              inspection_item: {
                status: "defect",
                comment: "Found a crack",
              },
              format: :turbo_stream,
            }

      inspection_item.reload
      expect(inspection_item.status).to eq("ok")
      expect(response).to redirect_to(inspection_path(inspection))
      expect(flash[:alert]).to eq(I18n.t("inspection_items.update.completed_alert"))
    end

    it "raises RecordNotFound for another user's inspection" do
      country = create(:country)
      user_a = create(:user, country: country)
      user_b = create(:user, country: country)
      template = create(:inspection_template, country: country)
      inspection = create(:inspection, user: user_b, inspection_template: template)
      checklist_item = create(:checklist_item, inspection_template: template)
      inspection_item = create(:inspection_item, inspection: inspection, checklist_item: checklist_item, status: :ok)
      sign_in(user_a)

      expect do
        patch :update,
              params: {
                inspection_id: inspection.id,
                id: inspection_item.id,
                inspection_item: {
                  status: "defect",
                  comment: "Found a crack",
                },
                format: :turbo_stream,
              }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
