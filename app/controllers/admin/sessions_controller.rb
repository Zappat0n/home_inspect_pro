class Admin::SessionsController < Devise::SessionsController
  layout "rails_admin_login"

  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield(resource) if block_given?
    respond_to do |format|
      format.html { render("admin/sessions/new") }
    end
  end

  private

  def after_sign_in_path_for(_resource)
    rails_admin.dashboard_path
  end

  def after_sign_out_path_for(_resource)
    new_admin_user_session_path
  end
end
