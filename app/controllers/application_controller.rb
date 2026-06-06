class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  private

  def after_sign_out_path_for(_resource)
    new_user_session_path
  end
end
