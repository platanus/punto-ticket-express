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
      PTE::Xls.autofit_cells_size sheet
    end

    def generate_book file_name, path, zip_file_name = nil
      file_name += ".xlsx" unless file_name.include? '.xlsx'
      complete_path = generate_directory path
      file_path = File.join(complete_path, file_name)
      @book.write(file_path)
      return compress(complete_path, file_name, zip_file_name) if zip_file_name
      file_path
    end

    def self.autofit_cells_size sheet
      (0...sheet.column_count).each do |col|
        width = 1
        row = 0
        sheet.column(col).each do |cell|
          if cell.nil? or cell.to_s.empty?
            w = 1
          else
            w = cell.to_s.strip.split('').count
          end

          ratio = sheet.row(row).format(col).font.size / 10
          w = (w * ratio).round
          width = w if w > width
          row += 1
        end
        sheet.column(col).width = width
      end
    end

    def generate_directory path
      unique_directory_name = Time.now.to_datetime.strftime("%d%m%Y%H%M%S")
      complete_path = File.join(Rails.public_path, path, unique_directory_name)
      FileUtils.mkdir_p(complete_path) unless File.directory?(complete_path)
      complete_path
    end

    def compress path, file_name, zip_file_name
      zip_file_name += ".zip" unless zip_file_name.include? '.zip'
      zip_path = File.join(path, zip_file_name)

      ::Zip::ZipFile.open(zip_path, 'w') do |zip_file|
        Dir.foreach(path) do |saved_file_name|
          zip_file.add(file_name, File.join(path, file_name)) if saved_file_name == file_name
        end
      end

      zip_path
    end
  end
end
