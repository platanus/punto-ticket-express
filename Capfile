# CAPISTRANO
CAPFILE_VERSION = "2.6.0"

# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Osx notifications
require 'capistrano-nc/nc'

# Github deployments
require 'capistrano/github'

# Ruby
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/rails/console'

# Node
require 'capistrano/nodenv'
require 'capistrano/bower'

# App server
require 'capistrano3/unicorn'

# Static server
require 'capistrano/nginx'

# Tools
require 'capistrano/delayed-job'
require 'whenever/capistrano'
#require 'thinking_sphinx/capistrano'

# Eye monitoring
require 'negroku/capistrano/eye'
require 'negroku/capistrano/eye/unicorn'
require 'negroku/capistrano/eye/delayed_job'
#require 'negroku/capistrano/eye/thinking_sphinx'

# NEGROKU
# Includes negroku defaults, tasks and check for updates
require 'negroku/capistrano/deploy'
require 'negroku/capistrano/update'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
