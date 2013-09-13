every 1.minute do
  set :output, "log/cron.log"
  rake "pte:cron:deactivate_old_pending_transactions", :environment => :development
end

every 5.minute do
  set :output, "log/cron.log"
  rake "pte:cron:deactivate_old_pending_transactions", :environment => :production
end
