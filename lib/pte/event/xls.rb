module PTE
  module Event
    class Xls
      def self.generate_participants_book event_id, file_name
        @xls = PTE::Xls.new
        sheet = @xls.add_sheet "Participantes"        
        @xls.load_data sheet, [["A1", "B1"], ["A2", "B2"]]
        @xls.generate_book file_name, "participants_xls"
      end
    end
  end
end
