RailsAdmin.config do |config|
  config.asset_source = :webpacker
  config.parent_controller = "Admin::BaseController"

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate!(scope: :admin_user)
  end
  config.current_user_method(&:current_admin_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.model("AdminUser") do
    field :email
    field :password do
      help "Password is required when creating or updating"
    end
    field :password_confirmation
    field :remember_created_at
    field :created_at
    field :updated_at
  end

  config.model("User") do
    field :email
    field :password do
      help "Password is required when creating or updating"
    end
    field :password_confirmation
    field :country
    field :trial_ends_at
    field :remember_created_at
    field :reset_password_sent_at
    field :reset_password_token
    field :stripe_customer_id
    field :created_at
    field :updated_at
  end

  config.model("InspectionTemplate::Item") do
    label_plural "Checklist items"
  end

  config.model("InspectionTemplate::Category") do
    visible false
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
