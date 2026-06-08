# frozen_string_literal: true

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature

  config.before(:each, type: :feature) do
    Warden.test_mode!
  end

  config.after(:each, type: :feature) do
    Warden.test_reset!
  end
end
