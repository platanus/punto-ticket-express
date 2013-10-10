source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'mysql2'
gem 'devise'
gem 'chronic'
gem 'activeadmin', '0.6.1'
gem "meta_search", '>= 1.1.0.pre'
gem 'rails-i18n'
gem 'devise-i18n'
gem 'jquery-rails', '~> 2.3.0'
gem 'haml'
gem 'cancan'
gem 'rubyzip', :require => 'zip/zip'
gem 'spreadsheet'
# amazon ses
gem "aws-ses", "~> 0.5.0", :require => 'aws/ses'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'validates_email_format_of'
gem 'colorize'
gem 'puntopagos'
gem 'yard'
gem 'whenever', :require => false
gem 'rqrcode'
gem 'paperclip', "~> 3.0"
gem 'aws-sdk', "~> 1.5.7"
gem 'will_paginate', '~> 3.0'
gem 'active_decorator'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "therubyracer"
  gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
  gem "less-rails-bootstrap"
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'unicorn'
end

group :development, :test do
  gem 'thin'
  gem 'haml-rails'
  gem 'hpricot'
  gem 'html2haml'
  gem 'faker'
  gem 'debugger'
  gem 'letter_opener'
end

group :development do
  gem 'negroku', '~> 1.1.4'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Deploy with Capistrano
# gem 'capistrano'
