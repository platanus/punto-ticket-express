module PTE
  module Util
    class Faker
      require 'faker'

      def self.load_app_data
        delete_old_data
        create_users
        create_ticket_buyers
        create_events
        puts "Done!"
      end

      def self.delete_old_data
        User.delete_all
        TicketType.delete_all
        Event.delete_all
        Ticket.delete_all
      end

      def self.create_users
        create_user("user@example.com", 12345678, PTE::Role.admin)
        create_user("super@admin.com", 12345678, PTE::Role.admin)

        @user_ids = [          
          create_user("one@user.com", 12345678, PTE::Role.user).id,
          create_user("two@user.com", 12345678, PTE::Role.user).id,
          create_user("three@user.com", 12345678, PTE::Role.user).id
        ]
        puts "#{@user_ids.size} Users loaded..."
      end

      def self.create_ticket_buyers
        @buyer_ids = []
        [*5..15].sample.times do
          @buyer_ids << create_user(::Faker::Internet.email, 12345678, PTE::Role.user).id
        end
        puts "#{@buyer_ids.size} Buyers loaded..."
      end

      def self.create_user email, password, role
        User.find_or_create_by_email(email, password: password, role: role)
      end

      def self.create_events
        events = []

        [*5..10].sample.times do
          events << create_event.id
        end
        puts "#{events.size} Events loaded..."
      end

      def self.create_event
        start_time = rand_time(Time.now - 20.days, Time.now + 20.days)

        evt = Event.create(
          name: ::Faker::Name.name,
          address: complete_address,
          description: ::Faker::Lorem.paragraphs([*2..6].sample),
          organizer_name: ::Faker::Name.name,
          organizer_description: ::Faker::Lorem.paragraphs([*1..3].sample),
          custom_url: ::Faker::Internet.url,
          user_id: @user_ids.sample,
          is_published: random_boolean,
          start_time: start_time,
          end_time: start_time + ([*10000..30000].sample)
        )

        create_ticket_types evt.id
        evt
      end

      def self.random_boolean
        (rand(10) % 2) == 1
      end

      def self.complete_address
        [::Faker::Address.street_name,        
         ::Faker::Address.city,
         ::Faker::Address.state,
         ::Faker::Address.country].join(", ")
      end

      def self.rand_time(from, to = Time.now)
        Time.at(rand_in_range(from.to_f, to.to_f))
      end

      def self.rand_in_range from, to
        rand * (to - from) + from
      end

      def self.create_ticket_types event_id
        ticket_types = []

        [*2..4].sample.times do
          ticket_types << create_ticket_type(event_id)
        end
        puts "#{ticket_types.size} Ticket Types loaded for event_id #{event_id}..."
      end

      def self.create_ticket_type event_id
        ticket_type = TicketType.create(
          event_id: event_id,
          name: random_ticket_type_name,
          price: [*200..800].sample,
          quantity: [*50..400].sample
        )

        create_tickets ticket_type
      end

      def self.random_ticket_type_name
        ["Platea", "Palco", "Tribuna", "Campo", "Vip", "Popular"].sample
      end

      def self.create_tickets ticket_type
        ticket_ids = []
        [*5..15].sample.times do
          ticket_ids << create_ticket(ticket_type).id
        end
        puts "#{ticket_ids.size} Tickets loaded for Ticket Type #{ticket_type.id}..."
      end

      def self.create_ticket ticket_type
        Ticket.create({
          user_id: @buyer_ids.sample,
          ticket_type_id: ticket_type.id,
          payment_status: PTE::PaymentStatus::STATUSES.sample,
          quantity: [*1..(ticket_type.available_tickets_count.to_f * 10.0 / 100.0).round].sample})
      end
    end
  end
end