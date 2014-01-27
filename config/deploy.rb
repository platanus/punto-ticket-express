# Set server stages
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

# Server-side information.
set :application, "punto-ticket-express"
set :user,        "deploy"
set :deploy_to,   "/home/#{user}/applications/#{application}"

# Repository (if any) configuration.
set :deploy_via, :remote_cache
set :repository, "git@github.com:platanus/punto-ticket-express.git"
# set :git_enable_submodules, 1

# Delayed jobs
require "delayed/recipes"
after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
after "deploy:restart", "delayed_job:stop", "delayed_job:start"

# Database
# set :migrate_env,    "migration"

# Unicorn
set :unicorn_workers, 1

set :use_ssl, true

set :whenever_roles, [:web, :app]
require "whenever/capistrano"

after "deploy", "whenever:update_crontab"
