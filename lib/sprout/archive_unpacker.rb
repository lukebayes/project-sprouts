require 'zip/zip'

module Sprout

  class ArchiveUnpackerError < StandardError; end #:nodoc:

  # Given a source, destination and type (or ability to infer it),
  # unpack downloaded archives.
  class ArchiveUnpacker

    def unpack archive, destination, clobber=nil
      validate_archive(archive)
      validate_destination(destination)

      return unpack_zip archive, destination, clobber if is_zip?(archive)

      raise ArchiveUnpackerError.new "Unsupported or unknown archive type encountered with: #{archive}"
    end

    def unpack_zip archive, destination, clobber=nil
      Zip::ZipFile.open archive do |zipfile|
        zipfile.each do |entry|
          unpack_zip_entry entry, destination, clobber
        end
      end
    end

    def is_zip? archive 
      !archive.match(/\.zip$/).nil?
    end

    private

    def validate_archive archive
      message = "Archive could not be found at: #{archive}"
      raise ArchiveUnpackerError.new(message) if archive.nil? || !File.exists?(archive)
    end

    def validate_destination path
      message = "Archive destination could not be found at: #{path}"
      raise ArchiveUnpackerError.new(message) if path.nil? || !File.exists?(path)
    end

    def unpack_zip_entry entry, destination, clobber
      # Ensure hidden mac files don't get written to disk:
      return if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
      path = File.join destination, entry.name

      if entry.directory?
        FileUtils.mkdir_p path
      elsif entry.file?
        entry.extract path do |failed_entry, failed_dest|
          FileUtils.rm_rf failed_dest if clobber == :clobber
        end
      end
    end

  end
end

