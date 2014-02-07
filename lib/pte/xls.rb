module PTE
  class Xls
    require 'fileutils'
    require 'spreadsheet'

    def self.save file, directory_path, file_name
      validate_file_to_read file
      file_name = file.original_filename unless file_name
      new_directory = PTE::FileUtils.generate_tmp_directory(directory_path)
      new_file_path = new_directory + '/' + file_name
      File.open(new_file_path, 'wb') { |f| f.write(file.read) }
      new_directory
    end

    def self.validate_file_to_read file
      raise PTE::Exceptions::XlsNoFileError unless file

      # This is not working on mac
      # if file.content_type != "application/vnd.ms-excel"
      #   raise PTE::Exceptions::InvalidXlsFileError
      # end
    end

    def self.read file_path
      Spreadsheet.open(file_path) do |book|
        book.worksheets.each do |ws|
          0.upto ws.last_row_index do |index|
            row = ws.row(index)
            yield ws, row
          end
        end
      end
    end

    def initialize
      @book = Spreadsheet::Workbook.new
    end

    def add_sheet name
      @book.create_worksheet :name => name
    end

    def load_data sheet, data
      data.each_with_index { |row, row_number| sheet.insert_row(row_number, row) }
      PTE::Xls.autofit_cells_size sheet
    end

    def generate_book file_name, path, zip_file_name = nil
      file_name += '.xls' unless file_name.include? '.xls'
      complete_path = PTE::FileUtils.generate_tmp_directory path
      file_path = File.join(complete_path, file_name)
      @book.write(file_path)
      return PTE::FileUtils.compress(complete_path, file_name, zip_file_name) if zip_file_name
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
  end
end
