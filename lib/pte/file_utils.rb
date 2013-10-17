module PTE
  class FileUtils
    require 'fileutils'
    # Generates unique directory into tmp directory
    # @param path [string] directory into tmp directory.
    #  The structure will be: /tmp/path_param
    #  For example: /tmp/xls_files
    # @return [string] root/tmp/path_param/unique_directory. For example: /home/puntot/tmp/xls_files/20131022777666
    def self.generate_tmp_directory path
      unique_directory_name = Time.now.to_datetime.strftime("%d%m%Y%H%M%S")
      complete_path = File.join(tmp_path, path, unique_directory_name)
      ::FileUtils.mkdir_p(complete_path) unless File.directory?(complete_path)
      complete_path
    end

    # Compress file into given directory
    # @param path [string] directory containing file to compress.
    #  For example: /home/puntot/tmp/xls_files/20131022777666
    # @param file_name [string] file name wich represents the file to compress.
    #  For example: participants.xls
    # @param zip_file_name [string] file name that will have the compressed file.
    #  For example: participants.zip
    # @return [string] The zip path. For example: /home/puntot/tmp/xls_files/20131022777666/participants.zip
    def self.compress path, file_name, zip_file_name
      zip_file_name += ".zip" unless zip_file_name.include? '.zip'
      zip_path = File.join(path, zip_file_name)

      ::Zip::ZipFile.open(zip_path, 'w') do |zip_file|
        Dir.foreach(path) do |saved_file_name|
          zip_file.add(file_name, File.join(path, file_name)) if saved_file_name == file_name
        end
      end

      zip_path
    end

    # Removes files and directories on given path
    # @param path [string] Directory containing files and directories to be deleted.
    # @param how_old [integer] Represents how minutes old should be the files to be deleted.
    def self.clean_old_files path, how_old = 60
      return unless dir_exist? path
      how_old = how_old * 60 #1 min = 60 seconds

      Dir.foreach(path) do |file|
        next if file == '.' or file == '..'
        file_to_delete = File.join(path.to_s, file.to_s)
        creation_time = File.mtime(file_to_delete).to_i
        delete_time = Time.now.to_i - how_old
        ::FileUtils.rm_rf(file_to_delete) if dir_exist?(file_to_delete) and creation_time < delete_time
      end
    end

    def self.tmp_path
      File.join(Rails.root.to_s, "tmp")
    end

    def self.dir_exist? path
      File.exists?(path) and File.directory?(path)
    end

  end
end
