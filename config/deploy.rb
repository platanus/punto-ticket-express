#########################################
# Negroku deploy.rb configuration file
#
# There are three types of settings here
#  * Capistrano settings
#  * Gem specific settings
#  * Negroku settings

######################
# Capistrano settings
# You can customize this settings at your will.
# Here you can find information about capistrano settings
# http://capistranorb.com/documentation/getting-started/preparing-your-application/
#
# Also Negroku sets some defaults that you can override
# here you can learn what are those defaults
# https://github.com/platanus/negroku/blob/master/lib/negroku/deploy.rb

set :application,   'punto-ticket-express'
set :repo_url,      'git@github.com:platanus/punto-ticket-express.git'
set :deploy_to,     "/home/deploy/applications/#{fetch(:application)}"

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []) + %w{}

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []) + %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

######################
# Unicorn
# You can find the default setting here
# https://github.com/tablexi/capistrano3-unicorn
#
# Also negroku adds some unicorn settings, here are the defaults
# https://github.com/platanus/negroku/blob/master/lib/negroku/deploy/unicorn.rb
# This are some example you might want to change that will not brake anything

# set :unicorn_template_type, "rails_activerecord"
# set :unicorn_workers, 1
# set :unicorn_workers_timeout, 30
