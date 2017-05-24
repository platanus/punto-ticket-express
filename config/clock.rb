require 'clockwork'
require_relative './boot'
require_relative './environment'

module Clockwork
  # Example
  #
  # every 50.minutes do
  #   rake "pte:cron:deactivate_old_pending_transactions", :environment => :development
  # end

  # every 5.minutes do
  #   rake "pte:cron:deactivate_old_pending_transactions", :environment => :production
  # end

  # every 20.minutes do
  #   rake "pte:cron:clean_old_participant_files", :environment => :development
  # end

  # every 50.minutes do
  #   rake "pte:cron:clean_old_participant_files", :environment => :production
  # end
end
