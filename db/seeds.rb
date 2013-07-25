# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#  get fixtures in YML format
require 'active_record/fixtures'

puts '--------------------------------------------------------'
puts 'DEFAULT USER'
puts '--------------------------------------------------------'
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "users")
