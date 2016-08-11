source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '3.2.13'
gem 'pg'
gem 'devise'
gem 'chronic'
gem 'activeadmin', '0.6.1'
gem "meta_search", '>= 1.1.0.pre'
gem 'rails-i18n'
gem 'devise-i18n'
gem 'jquery-rails', '~> 2.3.0'
gem 'cancan'
gem 'rubyzip', :require => 'zip/zip'
gem 'spreadsheet'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'validates_email_format_of'
gem 'colorize'
gem 'puntopagos'
gem 'yard'
gem 'rqrcode'
gem 'paperclip', "~> 3.0"
gem 'daemons'
gem 'delayed_job_active_record'
# amazon SES, S3
gem 'aws-sdk', "~> 1.22.1"
gem 'will_paginate', '~> 3.0'
gem 'active_decorator'
gem 'date_validator'
gem 'puma'
gem 'clockwork'
gem 'faker'

# Gems used only for assets and not required
# in production environments by default.

group :assets do
  gem "therubyracer"
  gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
  gem "less-rails-bootstrap"
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'ngmin-rails'
end

group :production do
  gem 'rack-timeout'
end

group :development, :test do
  gem 'thin'
  gem 'hpricot'
  gem 'byebug'
  gem 'letter_opener'
  gem 'zeus'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'dotenv-rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'rspec_junit_formatter', '0.2.2'
end

group :production do
end
