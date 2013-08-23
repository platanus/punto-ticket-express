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
        Producer.delete_all
        Transaction.delete_all
      end

      def self.create_users
        create_user("user@example.com", 12345678, PTE::Role.admin)
        create_user("super@admin.com", 12345678, PTE::Role.admin)

        @users = [
          create_user("one@user.com", 12345678, PTE::Role.user),
          create_user("two@user.com", 12345678, PTE::Role.user),
          create_user("three@user.com", 12345678, PTE::Role.user)
        ]
        puts "#{@users.size} Users loaded..."
      end

      def self.create_ticket_buyers
        @buyer_ids = []
        [*5..15].sample.times do
          @buyer_ids << create_user(::Faker::Internet.email, 12345678, PTE::Role.user).id
        end
        puts "#{@buyer_ids.size} Buyers loaded..."
      end

      def self.create_user email, password, role
        user = User.find_or_create_by_email(email, password: password, role: role)
        create_producers(user) if user.role == PTE::Role.user
        user
      end

      def self.create_producers user
        [*2..5].sample.times do
          producer = Producer.create(
            name: ::Faker::Name.name,
            address: complete_address,
            contact_email: ::Faker::Internet.email,
            contact_name: ::Faker::Name.name,
            description: ::Faker::Lorem.paragraphs([*2..6].sample),
            phone: ::Faker::PhoneNumber.phone_number,
            rut: valid_ruts.sample,
            website: ::Faker::Internet.url
          )

          producer.users << user
        end
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
        organizer = @users.sample

        evt = Event.create(
          name: ::Faker::Name.name,
          address: complete_address,
          description: ::Faker::Lorem.paragraphs([*2..6].sample),
          organizer_name: ::Faker::Name.name,
          organizer_description: ::Faker::Lorem.paragraphs([*1..3].sample),
          custom_url: ::Faker::Internet.url,
          user_id: organizer.id,
          is_published: random_boolean,
          producer_id: organizer.producers.sample.id,
          start_time: start_time,
          end_time: start_time + ([*10000..30000].sample)
        )

        create_ticket_types evt.id
        evt
      end

      def self.valid_ruts
        ["46741787-8",
         "39416659-6",
         "53512551-1",
         "76599154-4",
         "72779653-3",
         "58424819-K",
         "26931538-5",
         "18719247-1",
         "42437963-8",
         "79418519-0"]
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
      end

      def self.random_ticket_type_name
        ["Platea", "Palco", "Tribuna", "Campo", "Vip", "Popular"].sample
      end
    end
  end
end