module PTE
  class Xls
    require 'fileutils'
    require 'spreadsheet'

    def initialize
      @book = Spreadsheet::Workbook.new
    end

    def add_sheet name
      @book.create_worksheet :name => name
    end

    def load_data sheet, data
      data.each_with_index do |row, row_number|
        sheet.insert_row(row_number, row)
      end
    end

    def generate_book file_name, path
      complete_path = generate_directory path
      @book.write(File.join(complete_path, file_name))
      File.join(complete_path, file_name)
    end

    def generate_directory path
      unique_directory_name = Time.now.to_datetime.strftime("%d%m%Y%H%M%S")
      complete_path = File.join(Rails.public_path, path, unique_directory_name)
      FileUtils.mkdir_p(complete_path) unless File.directory?(complete_path)
      complete_path
    end
  end
end
