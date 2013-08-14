# -*- coding: utf-8 -*-
namespace :pte do
  namespace :util do 
    desc "Loads development fake data for users, tickets, events, tycket types, etc."
    task :load_fake_data => :environment do
      require 'tasks/pte/util/faker.rb'
      if Rails.env == "production"
        puts "You can't run this taks on production environment"
        return
      end
      PTE::Util::Faker.load_app_data
    end
  end
end