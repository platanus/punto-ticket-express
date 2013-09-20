set :job_template, "bash -lc ':job'"
set :output, "log/cron.log"

every 15.minute do
  rake "pte:cron:deactivate_old_pending_transactions", :environment => :development
end

every 5.minutes do
  rake "pte:cron:deactivate_old_pending_transactions", :environment => :production
end
