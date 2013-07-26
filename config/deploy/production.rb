## PRODUCTION CONFIGURATION

# Servers and their roles.
server "szot.platan.us", :web, :app, :db, primary: true

# Web server configuration
set :domains, 		"www.punto-ticket-express.com"

# Source
set :branch,     	"production"		# Optional, defaults to master
# set :remote,   	"origin"			# Optional, defaults to origin

# Rails
# set :rails_env, 	"production"		# Optional, defaults to production
