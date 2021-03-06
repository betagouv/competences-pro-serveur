# frozen_string_literal: true

ruby '2.7.3'
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Reduces boot times through caching; required in config/boot.rb
gem 'activeadmin'
gem 'activeadmin_addons'
gem 'active_admin-humanized_enum'
gem 'activeadmin_reorderable'
gem 'activeadmin-xls'
gem 'acts_as_list'
gem 'addressable'
gem 'auto_strip_attributes', '~> 2.6'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.3', '>= 4.3.1'
gem 'cancancan'
gem 'coffee-rails'
gem 'descriptive_statistics', '~> 2.4.0', require: 'descriptive_statistics/safe'
gem 'devise'
gem 'devise-i18n'
gem 'ffaker'
gem 'geocoder'
gem 'jbuilder'
gem 'kaminari-i18n'
gem 'mini_racer'
gem 'pg', '~> 1.0'
gem 'rack-cors', require: 'rack/cors'
gem 'rails-i18n'
gem 'rails-observers'
gem 'recipient_interceptor'
gem 'redcarpet'
gem 'redis'
gem 'rollbar'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'truemail'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary', '~> 0.12.3.1'

source 'https://rails-assets.org' do
  gem 'rails-assets-clipboard'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'listen', '~> 3.2'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'rspec-rails'
end

group :development do
  gem 'foreman'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  gem 'letter_opener'
  gem 'rails-erd'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'tarteaucitron'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'pdf-reader'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers'
end
