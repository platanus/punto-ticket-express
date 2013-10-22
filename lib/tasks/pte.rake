# -*- coding: utf-8 -*-
namespace :pte do
  desc "Creates GlobalConfiguration instance with default values"
  task :create_config_instance => :environment do
    GlobalConfiguration.delete_all
    GlobalConfiguration.create({fixed_fee: 0.0, percent_fee: 0.0})
  end

  namespace :util do
    desc "Loads development fake data for users, tickets, events, ticket types, etc."
    task :load_fake_data => :environment do
      require 'tasks/pte/util/faker.rb'
      if Rails.env == "production"
        puts "You can't run this taks on production environment"
        return
      end
      PTE::Util::Faker.load_app_data
    end
  end
  namespace :cron do
    require 'tasks/pte/cron.rb'
    desc "Changes payment_status from processing to inactive for transactions that have been processing status for 15 minutes or more"
    task :clean_old_participant_files => :environment do
      PTE::Cron.clean_old_participant_files
    end

    desc "Cleans /tmp/participants_xls directory. Deletes files 60 minutes old or more."
    task :clean_old_participant_files => :environment do
      PTE::Cron.clean_old_participant_files
    end
  end
end
