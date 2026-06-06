# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :detect_country, only: :create

  def create
    super
  end

  private

  def detect_country
    country = CountryDetectionService.new(request.remote_ip).call
    params[:user][:country_id] = country.id
  end

  def sign_up_params
    params.expect(user: [:email, :password, :password_confirmation, :country_id])
  end
end
