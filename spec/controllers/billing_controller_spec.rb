require "rails_helper"

RSpec.describe BillingController, type: :controller do
  render_views

  describe "GET #show" do
    it "redirects to sign in when not authenticated" do
      get :show

      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows subscribe buttons when not subscribed" do
      user = create(:user)
      user.set_payment_processor(:paddle_billing)
      user.payment_processor.update_column(:processor_id, "ctm_test123")

      sign_in user
      get :show

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Subscribe Monthly")
      expect(response.body).to include("Subscribe Yearly")
    end

    it "shows active subscription message when subscribed" do
      user = create(:user)
      user.set_payment_processor(:paddle_billing)
      user.payment_processor.update_column(:processor_id, "ctm_test123")
      Pay::PaddleBilling::Subscription.create!(
        customer: user.payment_processor,
        name: "default",
        processor_id: "sub_test123",
        processor_plan: "pri_monthly",
        status: "active",
        current_period_start: Time.current,
        current_period_end: 1.month.from_now,
      )

      sign_in user
      get :show

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("You have an active subscription")
    end
  end
end
