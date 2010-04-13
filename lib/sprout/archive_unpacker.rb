require 'zip/zip'

module Sprout

  class ArchiveUnpackerError < StandardError; end #:nodoc:

  # Given a source, destination and type (or ability to infer it),
  # unpack downloaded archives.
  class ArchiveUnpacker

    def unpack archive, destination, clobber=nil
      validate_archive(archive)
      validate_destination(destination)

      return unpack_zip(archive, destination, clobber) if is_zip?(archive)

      raise ArchiveUnpackerError.new("Unsupported or unknown archive type encountered with: #{archive}")
    end

    def unpack_zip archive, destination, clobber=nil
      Zip::ZipFile.open archive do |zipfile|
        zipfile.each do |entry|
          next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
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
      path = File.join destination, entry.name

      if entry.directory?
        # If an archive has empty directories:
        FileUtils.mkdir_p path
      elsif entry.file?
        # On Windows, we don't get the entry for
        # each parent directory:
        FileUtils.mkdir_p File.dirname(path)
        begin
          entry.extract path
        rescue Zip::ZipDestinationFileExistsError => zip_dest_error
          if(clobber == :clobber)
            FileUtils.rm_rf path
            entry.extract path
          else
            raise zip_dest_error
          end
        end
      end
    end

  end
end

