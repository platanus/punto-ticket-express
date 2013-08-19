module PTE
  module Event
    class Xls
      extend PTE::Xls

      def self.generate_participants_book event_id
        puts "generate_participants_book"
        generate_book
      end
    end
  end
end
