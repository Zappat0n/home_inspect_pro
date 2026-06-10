source "https://rubygems.org"

# Pin to the default gem version shipped with Ruby to avoid duplicate psych
# versions (default + installed) which trigger Bundler ambiguity warnings.
gem "bootsnap", ">= 1.24.1", require: false
gem "dartsass-rails", "~> 0.5.1"
gem "image_processing", "~> 2.0"
gem "pg", "~> 1.1"
gem "propshaft"
gem "psych", "~> 5.3.0"
gem "puma", ">= 7.1"
gem "rails", github: "rails/rails", branch: "main"
gem "shakapacker"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "stimulus-rails"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]
# Authentication [https://github.com/heartcombo/devise]
gem "devise"
# IP-based geolocation [https://github.com/alexreisner/geocoder]
gem "geocoder"
gem "lucide-rails"
# PDF generation via Puppeteer [https://github.com/Studiosity/grover]
gem "grover"
# Payment processing via Paddle (MoR) [https://github.com/pay-rails/pay]
gem "paddle"
gem "pay"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# S3-compatible service adapter for Active Storage (Cloudflare R2 in production)
gem "aws-sdk-s3", require: false
gem "rails_admin", "~> 3.0"
gem "ruby-vips", "~> 2.3"

group :development, :test do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "capybara"
  gem "cuprite"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "factory_bot_rails"
  gem "i18n-tasks"
  gem "rspec-rails", "~> 8.0.0"
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
end

group :development do
  gem "annotaterb", require: false
  gem "kamal", require: false
  gem "listen", "~> 3.9"
  gem "rails-ai-context"
  gem "web-console"
end
