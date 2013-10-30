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
        create_producers(user) if user.role.to_s == PTE::Role.user.to_s
        puts "#{user.role} role - email: #{user.email}, pass: #{password}".green if show_ouput
        user
      end

      def self.create_producers user
        [*2..5].sample.times do
          producer = Producer.create!(
            name: "Productora " + ::Faker::Name.name,
            address: complete_address,
            contact_email: ::Faker::Internet.email,
            contact_name: ::Faker::Name.name,
            description: ::Faker::Lorem.paragraphs([*2..6].sample),
            phone: ::Faker::PhoneNumber.phone_number,
            rut: valid_ruts.sample,
            website: ::Faker::Internet.url,
            corporate_name: ::Faker::Name.name,
            fixed_fee: [*1000..3000].sample,
            percent_fee: [*10..50].sample
          )

          producer.users << user
        end
      end

      def self.create_events
        [*40..50].sample.times do
          create_event
        end
      end

      def self.create_event
        start_time = rand_time(Time.now - 20.days, Time.now + 20.days)
        organizer = @organizers.sample
        producer = organizer.producers.try(:sample)

        evt = Event.create(
          name: "Evento " + ::Faker::Name.name,
          address: complete_address,
          description: ::Faker::Lorem.paragraphs([*2..6].sample),
          custom_url: ::Faker::Internet.url,
          user_id: organizer.id,
          is_published: random_boolean,
          producer_id: producer.id,
          start_time: start_time,
          end_time: start_time + ([*10000..30000].sample),
          fixed_fee: producer.fixed_fee,
          percent_fee: producer.percent_fee
        )

        create_ticket_types(evt.id)
        create_event_promotions(evt.id)
        create_transactions(evt)
        evt
      end

      def self.create_transactions event
        return unless event.is_published?
        [*2..20].sample.times do
          create_transaction(event.ticket_types[1..[*1..event.ticket_types.count].sample])
        end
      end

      def self.create_transaction ticket_types
        payment_status = PTE::PaymentStatus::STATUSES.sample.to_s

        data = {user_id: @buyer_ids.sample, transaction_time: Time.now}

        if payment_status == PTE::PaymentStatus.processing
          data[:payment_status] = PTE::PaymentStatus.processing

        elsif payment_status == PTE::PaymentStatus.completed
          data[:payment_status] = PTE::PaymentStatus.completed
          data[:token] = ::Faker::Number.number(10)

        elsif payment_status == PTE::PaymentStatus.inactive
          data[:payment_status] = PTE::PaymentStatus.inactive
          data[:error] = "Error message"

        else
          raise Exception.new("Invalid payment type")
        end

        transaction = Transaction.create(data)
        ticket_types.each do |tt|
          [*1..5].sample.times do
            create_ticket tt, transaction
          end
        end
      end

      def self.create_ticket ticket_type, transaction
        #most_convenient_promotion only uses percent and amount promotion types
        promotion_id = ticket_type.most_convenient_promotion.id rescue nil

        data = {
          ticket_type_id: ticket_type.id,
          transaction_id: transaction.id,
          promotion_id: promotion_id}

        Ticket.create(data)
      end

      def self.create_ticket_types event_id
        type_names = ticket_type_names
        [*1..3].sample.times do
          create_ticket_type(event_id, type_names.pop)
        end
      end

      def self.create_ticket_type event_id, ticket_type_name
        ticket_type = TicketType.create(
          event_id: event_id,
          name: ticket_type_name,
          price: [*2000..60000].sample,
          quantity: [*200..2000].sample
        )

        create_ticket_type_promotions(ticket_type.id)
      end

      def self.create_ticket_type_promotions ticket_type_id
        [*1..3].sample.times do
          create_promotion(ticket_type_id, 'TicketType')
        end
      end

      def self.create_event_promotions event_id
        [*1..3].sample.times do
          create_promotion(event_id, 'Event')
        end
      end

      def self.create_promotion promotable_id, promotable_type
        promo_type = PTE::PromoType::TYPES.sample.to_s
        start = (Date.today - [*-5..5].sample.days)

        data = {
          name: "Promo " + ::Faker::Name.name,
          start_date: start,
          end_date: (start + [*5..15].sample.days),
          promotable_id: promotable_id,
          promotable_type: promotable_type
        }

        data[:limit] = [*50..100].sample if random_boolean
        data[:activation_code] = ::Faker::Number.number(5).to_s if random_boolean

        if promo_type == PTE::PromoType.percent_discount
          data[:promotion_type] = PTE::PromoType.percent_discount
          data[:promotion_type_config] = [*5..50].sample

        elsif promo_type == PTE::PromoType.amount_discount
          data[:promotion_type] = PTE::PromoType.amount_discount
          data[:promotion_type_config] = [*1000..1800].sample

        elsif promo_type == PTE::PromoType.nx1
          data[:promotion_type] = PTE::PromoType.nx1
          data[:promotion_type_config] = (::Faker::Number.digit.to_i + 2)

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

      def self.ticket_type_names
        ["Platea", "Palco", "Tribuna", "Campo", "Vip", "Popular"]
      end
    end
  end
end
