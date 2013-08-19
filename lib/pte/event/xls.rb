module PTE
  module Event
    class Xls
      def self.generate_participants_book event, file_name
        xls = PTE::Xls.new
        sheet = xls.add_sheet I18n.t("xls.participants.sheet_name")
        load_participants_sheet xls, sheet, event     
        xls.generate_book file_name, "participants_xls"
      end

      def self.load_participants_sheet xls, sheet, event
        sheet_data = [[User.human_attribute_name(:email)]]
        event.users.each { |user| sheet_data << [user.email] }
        xls.load_data sheet, sheet_data       
      end
    end
  end
end
