class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
end
