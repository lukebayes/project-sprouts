require 'zip/zip'
require 'archive/tar/minitar'

module Sprout

  # Given a source, destination and type (or ability to infer it),
  # unpack downloaded archives.
  class ArchiveUnpacker

    def unpack archive, destination, clobber=nil
      validate_archive(archive)
      validate_destination(destination)

      return unpack_zip(archive, destination, clobber) if is_zip?(archive)
      return unpack_tgz(archive, destination, clobber) if is_tgz?(archive)

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

    def unpack_tgz archive, destination, clobber=nil
      tar = Zlib::GzipReader.new(File.open(archive, 'rb'))
      if(!should_unpack_tgz?(destination, clobber))
        raise DestinationExistsError.new "Unable to unpack #{archive} into #{destination} without explicit :clobber argument"
      end

      Archive::Tar::Minitar.unpack(tar, destination)

      # Recurse and unpack gzipped children (Adobe did this double 
      # gzip with the Linux FlashPlayer for some reason)
      ["#{destination}/**/*.tgz", "#{destination}/**/*.tar.gz"].each do |pattern|
        Dir.glob(pattern).each do |child|
          if(child != archive && dir != File.dirname(child))
            unpack_tgz(child, File.dirname(child))
          end
        end
      end
    end

    def is_zip? archive 
      !archive.match(/\.zip$/).nil?
    end

    def is_tgz? archive
      !archive.match(/\.tgz$/).nil? || !archive.match(/\.tar.gz$/).nil?
    end

    private

    def should_unpack_tgz? dir, clobber=nil
      return !directory_has_children?(dir) || clobber == :clobber

    end

    def directory_has_children? dir
      (Dir.entries(dir) - ['.', '..']).size > 0
    end

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
            raise DestinationExistsError.new zip_dest_error.message
          end
        end
      end
    end

  end
end

