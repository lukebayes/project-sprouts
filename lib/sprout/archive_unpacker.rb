require 'zip/zip'
require 'archive/tar/minitar'

module Sprout

  # Given a source, destination and type (or ability to infer it),
  # unpack downloaded archives.
  class ArchiveUnpacker

    # Figure out what kind of archive you have from the file name,
    # and unpack it using the appropriate scheme.
    def unpack archive, destination, clobber=nil
      return unpack_zip(archive, destination, clobber) if is_zip?(archive)
      return unpack_tgz(archive, destination, clobber) if is_tgz?(archive)

      # This is definitely debatable, should we copy the file even if it's
      # not an archive that we're about to unpack?
      # If so, why would we only do this with some subset of file types?
      # Opinions welcome here...
      return copy_file(archive, destination, clobber)  if is_copyable?(archive)

      raise UnknownArchiveType.new("Unsupported or unknown archive type encountered with: #{archive}")
    end

    # Unpack zip archives on any platform.
    def unpack_zip archive, destination, clobber=nil
      validate archive, destination

      Zip::ZipFile.open archive do |zipfile|
        zipfile.each do |entry|
          next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
          unpack_zip_entry entry, destination, clobber
        end
      end
    end

    # Unpack tar.gz or .tgz files on any platform.
    def unpack_tgz archive, destination, clobber=nil
      validate archive, destination

      tar = Zlib::GzipReader.new(File.open(archive, 'rb'))
      if(!should_unpack_tgz?(destination, clobber))
        raise DestinationExistsError.new "Unable to unpack #{archive} into #{destination} without explicit :clobber argument"
      end

      Archive::Tar::Minitar.unpack(tar, destination)

      # Recurse and unpack gzipped children (Adobe did this double 
      # gzip with the Linux FlashPlayer for some weird reason)
      ["#{destination}/**/*.tgz", "#{destination}/**/*.tar.gz"].each do |pattern|
        Dir.glob(pattern).each do |child|
          if(child != archive && dir != File.dirname(child))
            unpack_tgz(child, File.dirname(child))
          end
        end
      end
    end

    # Rather than unpacking, safely copy the file from one location
    # to another.
    def copy_file file, destination, clobber=nil
      validate file, destination
      target = File.expand_path( File.join(destination, File.basename(file)) )
      if(File.exists?(target) && clobber != :clobber)
        raise DestinationExistsError.new "Unable to copy #{file} to #{target} because target already exists and we were not asked to :clobber it"
      end
      FileUtils.mkdir_p destination
      FileUtils.cp_r file, destination

      destination
    end

    # Return true if the provided file name looks like a zip file.
    def is_zip? archive 
      !archive.match(/\.zip$/).nil?
    end

    # Return true if the provided file name looks like a tar.gz file.
    def is_tgz? archive
      !archive.match(/\.tgz$/).nil? || !archive.match(/\.tar.gz$/).nil?
    end

    def is_exe? archive
      !archive.match(/\.exe$/).nil?
    end
    
    def is_swc? archive
      !archive.match(/\.swc$/).nil?
    end

    def is_rb? archive
      !archive.match(/\.rb$/).nil?
    end

    private

    def is_copyable? archive
      (is_exe?(archive) || is_swc?(archive) || is_rb?(archive))
    end

    def should_unpack_tgz? dir, clobber=nil
      return !directory_has_children?(dir) || clobber == :clobber

    end

    def directory_has_children? dir
      (Dir.entries(dir) - ['.', '..']).size > 0
    end

    def validate archive, destination
      validate_archive archive
      validate_destination destination
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

