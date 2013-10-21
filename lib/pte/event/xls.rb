module PTE
  module Event
    class Xls
      PARTICIPANTS_DIRECTORY_NAME = "participants_xls"

      def self.generate_participants_book event
        xls = PTE::Xls.new
        file_name = I18n.t("xls.participants.file_name")
        zip_file_name = I18n.t("xls.participants.zip_file_name")
        transactions = event.transactions.completed
        sheet = xls.add_sheet I18n.t("xls.participants.sheet_name")
        load_participants_sheet xls, sheet, transactions
        xls.generate_book file_name, PARTICIPANTS_DIRECTORY_NAME#, zip_file_name #uncomment to download a zip file instead xlsx
      end

      def self.clean_old_participant_files
        dir = File.join(PTE::FileUtils.tmp_path, PARTICIPANTS_DIRECTORY_NAME)
        PTE::FileUtils.clean_old_files(dir, 1)
      end

      private

        def self.load_participants_sheet xls, sheet, transactions
          sheet_data = []

          xls_header = [
            NestedResource.human_attribute_name(:name),
            NestedResource.human_attribute_name(:last_name),
            NestedResource.human_attribute_name(:rut),
            NestedResource.human_attribute_name(:address),
            NestedResource.human_attribute_name(:age),
            NestedResource.human_attribute_name(:birthday),
            NestedResource.human_attribute_name(:company),
            NestedResource.human_attribute_name(:gender),
            NestedResource.human_attribute_name(:job),
            NestedResource.human_attribute_name(:job_address),
            NestedResource.human_attribute_name(:job_phone),
            NestedResource.human_attribute_name(:mobile_phone),
            NestedResource.human_attribute_name(:phone),
            NestedResource.human_attribute_name(:email),
            NestedResource.human_attribute_name(:website)
          ]

          sheet_data << xls_header

          transactions.each do |transaction|
            next unless transaction.nested_resource
            nested_resource = transaction.nested_resource
            sheet_data << [
              safe_resource_value(nested_resource, :name),
              safe_resource_value(nested_resource, :last_name),
              safe_resource_value(nested_resource, :rut),
              safe_resource_value(nested_resource, :address),
              safe_resource_value(nested_resource, :age),
              safe_resource_value(nested_resource, :birthday),
              safe_resource_value(nested_resource, :company),
              safe_gender_value(nested_resource),
              safe_resource_value(nested_resource, :job),
              safe_resource_value(nested_resource, :job_address),
              safe_resource_value(nested_resource, :job_phone),
              safe_resource_value(nested_resource, :mobile_phone),
              safe_resource_value(nested_resource, :phone),
              safe_resource_value(nested_resource, :email),
              safe_resource_value(nested_resource, :website)
            ]
          end
          xls.load_data sheet, sheet_data
        end

        def self.safe_gender_value nested_resource
          return "" unless nested_resource
          return I18n.t("gender.man") if nested_resource.gender
          I18n.t("gender.woman")
        end

        def self.safe_resource_value nested_resource, attr
          return "" unless nested_resource
          nested_resource[attr]
        end
    end
  end
end
