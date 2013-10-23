module PTE
  module Util
    class Faker
      require 'faker'
      DEFAULT_PASS = 12345678

      def self.load_app_data
        delete_old_data
        create_users
        create_ticket_buyers
        create_events

        puts "Done!".green
      end

      def self.delete_old_data
        User.delete_all
        TicketType.delete_all
        Event.delete_all
        Ticket.delete_all
        Producer.delete_all
        Promotion.delete_all
        ::Transaction.delete_all
      end

      def self.create_users
        create_user("one@admin.com", DEFAULT_PASS, PTE::Role.admin)
        create_user("two@admin.com", DEFAULT_PASS, PTE::Role.admin)

        @organizers = [
          create_user("one@organizer.com", DEFAULT_PASS, PTE::Role.user),
          create_user("two@organizer.com", DEFAULT_PASS, PTE::Role.user),
          create_user("three@organizer.com", DEFAULT_PASS, PTE::Role.user)
        ]
      end

      def self.create_ticket_buyers
        @buyer_ids = [create_user("one@user.com", DEFAULT_PASS, PTE::Role.user).id]

        [*5..15].sample.times do
          @buyer_ids << create_user(::Faker::Internet.email, DEFAULT_PASS, PTE::Role.user, false).id
        end
      end

      def self.create_user email, password, role, show_ouput = true
        user = User.find_or_create_by_email(email, password: password, role: role, name: ::Faker::Name.name)
        create_producers(user) if user.role == PTE::Role.user
        puts "#{user.role} role - email: #{user.email}, pass: #{password}".green if show_ouput
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
        [*5..10].sample.times do
          create_event
        end
      end

      def self.create_event
        start_time = rand_time(Time.now - 20.days, Time.now + 20.days)
        organizer = @organizers.sample

        evt = Event.create(
          name: ::Faker::Name.name,
          address: complete_address,
          description: ::Faker::Lorem.paragraphs([*2..6].sample),
          custom_url: ::Faker::Internet.url,
          user_id: organizer.id,
          is_published: random_boolean,
          producer_id: organizer.producer_ids.try(:sample),
          start_time: start_time,
          end_time: start_time + ([*10000..30000].sample)
        )

        create_ticket_types(evt.id)
        evt
      end

      def self.create_ticket_types event_id
        [*2..4].sample.times do
          create_ticket_type(event_id)
        end
      end

      def self.create_ticket_type event_id
        ticket_type = TicketType.create(
          event_id: event_id,
          name: random_ticket_type_name,
          price: [*40..80].sample,
          quantity: [*50..400].sample
        )

        create_promotions(ticket_type.id)
      end

      def self.create_promotions ticket_type_id
        [*1..3].sample.times do
          create_promotion(ticket_type_id)
        end
      end

      def self.create_promotion ticket_type_id
        promo_type = PTE::PromoType::TYPES.sample.to_s

        data = {
          name: ::Faker::Name.name,
          start_date: Date.today,
          end_date: (Date.today + [*50..150].sample.days),
          limit: [*50..500].sample,
          ticket_type_id: ticket_type_id
        }

        if promo_type == PTE::PromoType.code
          data[:promotion_type] = PTE::PromoType.code
          data[:activation_code] = ::Faker::Number.number(5)

        elsif promo_type == PTE::PromoType.percent_discount
          data[:promotion_type] = PTE::PromoType.percent_discount
          data[:promotion_type_config] = [*5..50].sample.to_s

        elsif promo_type == PTE::PromoType.amount_discount
          data[:promotion_type] = PTE::PromoType.amount_discount
          data[:promotion_type_config] = [*2000..5000].sample.to_s

        elsif promo_type == PTE::PromoType.nx1
          data[:promotion_type] = PTE::PromoType.nx1
          data[:promotion_type_config] = ::Faker::Number.digit

        else
          raise Exception.new("Invalid promo type")
        end

        Promotion.create(data)
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

      def self.random_ticket_type_name
        ["Platea", "Palco", "Tribuna", "Campo", "Vip", "Popular"].sample
      end
    end
  end
end
