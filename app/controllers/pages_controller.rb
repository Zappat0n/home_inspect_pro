# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home privacy support]

  def home
  end

  def privacy
  end

  def support
  end
end
