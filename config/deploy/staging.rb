## STAGING CONFIGURATION

# Servers and their roles.
server "kross.platan.us", :web, :app, :db, primary: true

# Web server configuration
set :domains, 		"pt-express-staging.platan.us"

# Source
set :branch,     	"staging"		# Optional, defaults to master
# set :remote,   	"origin"			# Optional, defaults to origin

# Rails
# set :rails_env, 	"staging"		# Optional, defaults to production
