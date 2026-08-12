source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
# Use Awesome Print for better printing
gem "awesome_print"
# Use Devise for authentication
gem "devise"
# Provide email subscriptions and one-click unsubscribe
gem "mailkick", "~> 1.3.1"
# Provide GDPR cookie consent controls
gem "immosquare-cookies", "~> 2.0"
# Use HTML2HAML to convert erb to haml
gem "html2haml"
# Use HAML for HTML templates
gem "haml-rails", "~> 2.0"
# Use sitemap generator to generate sitemaps
gem "sitemap_generator"
# Use Simple Form for forms
gem "simple_form"
# Use Rack Timeout to timeout requests
gem "rack-timeout"
# Use High Voltage for static pages
gem "high_voltage"
# Use Title for dynamic page titles
gem "title"
# Organize reusable, testable view components
gem "view_component", "~> 3.25"
# Use Sidekiq for background jobs
gem "sidekiq"
# Use Rubocop for linting
gem "rubocop", require: false
# Use Rubocap Rails for enforcing ruby on rails conventions
gem "rubocop-rails", require: false
# To upload assets to S3 after precompiling assets
gem "asset_sync"
# To use AWS with asset_sync
gem "fog-aws"

group :development, :test do
  # Document database columns in models
  gem "annotaterb", "~> 4.24", require: false
  # Use RSpec for testing
  gem "rspec-rails", "~> 6.1.0"
  # Use Factory Bot for fixtures
  gem "factory_bot_rails"
  # Use Timecop for time testing
  gem "timecop"
end

group :test do
  # Use Shoulda Matchers for test matchers
  gem "shoulda-matchers", "~> 6.0"
end
