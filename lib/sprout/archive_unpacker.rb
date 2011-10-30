require 'zip/zip'
require 'sprout/version'
require 'archive/tar/minitar'

##
# Given a source, destination and archive type (or ability to infer it),
# unpack the provided archive.
#
#   unpacker = Sprout::ArchiveUnpacker.new
#   unpacker.unpack "Foo.zip", "unpacked/"
#
class Sprout::ArchiveUnpacker

  ##
  # Unpack the provided +archive+ into the provided +destination+.
  #
  # If a +type+ is not provided, a type will be inferred from the file name suffix.
  #
  # @param archive [File] Path to the archive that will be unpacked (or copied)
  # @param destination [Path] Path to the folder where unpacked files should be placed (or copied).
  # @param type [Symbol] The type of the archive in cases where it can't be inferred
  #     from the name. Acceptable values are: :zip, :tgz, :swc, :exe or :rb
  # @param clobber [Boolean] If the destination already contains the expected file(s),
  #     the unpacker will not run unless +clobber+ is true.
  # @return [String] path to the unpacked files (usually same as destination).
  # @raise Sprout::Errors::UnknownArchiveType If the archive type cannot be inferred and a valid type is not provided.
  def unpack archive, destination, type=nil, clobber=nil
    return unpack_zip(archive, destination, clobber) if is_zip?(archive, type)
    return unpack_tgz(archive, destination, clobber) if is_tgz?(archive, type)

    # This is definitely debatable, should we copy the file even if it's
    # not an archive that we're about to unpack?
    # If so, why would we only do this with some subset of file types?
    # Opinions welcome here...
    return copy_file(archive, destination, clobber)  if is_copyable?(archive)

    raise Sprout::Errors::UnknownArchiveType.new("Unsupported or unknown archive type encountered with: #{archive}")
  end

  ##
  # Unpack zip archives on any platform using whatever strategy is most
  # efficient and reliable.
  #
  # @param archive [File] Path to the archive that will be unpacked.
  # @param destination [Path] Path to the folder where unpacked files should be placed.
  # @param clobber [Boolean] If the destination already contains the expected file(s),
  #     the unpacker will not run unless +clobber+ is true.
  # @return [File] the file or directory that was created.
  def unpack_zip archive, destination, clobber=nil
    validate archive, destination

    ##
    # As it turns out, the Rubyzip library corrupts
    # binary files (like the Flash Player) on OSX and is also
    # horribly slow for large archives (like the ~120MB Flex SDK)
    # on all platforms.
    if is_darwin?
      unpack_zip_on_darwin archive, destination, clobber
    else
      Zip::ZipFile.open archive do |zipfile|
        zipfile.each do |entry|
          next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
            unpack_zip_entry entry, destination, clobber
        end
      end
    end
  end

  ##
  # Return true if we're on a Darwin native system (OSX).
  # @return [Boolean]
  def is_darwin?
    Sprout.current_system.is_a?(Sprout::System::OSXSystem)
  end

  ##
  # Optimization for zip files on OSX. Uses the native
  # 'unzip' utility which is much faster (and more reliable)
  # than Ruby for large archives (like the Flex SDK) and
  # binaries that Ruby corrupts (like the Flash Player).
  #
  # @return [File] the file or directory that was created.
  def unpack_zip_on_darwin archive, destination, clobber
    # Unzipping on OS X
    FileUtils.makedirs destination
    zip_dir  = File.expand_path File.dirname(archive)
    zip_name = File.basename archive
    output   = File.expand_path destination
    # puts ">> zip_dir: #{zip_dir} zip_name: #{zip_name} output: #{output}"
    %x(cd #{zip_dir};unzip #{zip_name} -d #{output})
  end

  ##
  # Unpack tar.gz or .tgz files on any platform.
  #
  # @return [File] the file or directory that was created.
  def unpack_tgz archive, destination, clobber=nil
    validate archive, destination

    tar = Zlib::GzipReader.new(File.open(archive, 'rb'))
    if(!should_unpack_tgz?(destination, clobber))
      raise Sprout::Errors::DestinationExistsError.new "Unable to unpack #{archive} into #{destination} without explicit :clobber argument"
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

  ##
  # Rather than unpacking, safely copy the file from one location
  # to another.
  # This method is generally used when .exe files are downloaded
  # directly.
  #
  # @return [File] the file or directory that was created.
  def copy_file file, destination, clobber=nil
    validate file, destination
    target = File.expand_path( File.join(destination, File.basename(file)) )
    if(File.exists?(target) && clobber != :clobber)
      raise Sprout::Errors::DestinationExistsError.new "Unable to copy #{file} to #{target} because target already exists and we were not asked to :clobber it"
    end
    FileUtils.mkdir_p destination
    FileUtils.cp_r file, destination

    destination
  end

  ##
  # Returns true if the provided file name looks like a zip file or the +type+ argument is +:zip+.
  # @return [Boolean]
  def is_zip? archive, type=nil
    type == :zip || !archive.match(/\.zip$/).nil?
  end

  ##
  # Return true if the provided file name looks like a tar.gz file or the +type+ argument is +:tgz+.
  # @return [Boolean]
  def is_tgz? archive, type=nil
    type == :tgz || !archive.match(/\.tgz$/).nil? || !archive.match(/\.tar.gz$/).nil?
  end

  ##
  # Return true if the downloaded archive is a .exe file or the +type+ argument is +:exe+.
  # @return [Boolean]
  def is_exe? archive, type=nil
    type == :exe || !archive.match(/\.exe$/).nil?
  end

  ##
  # Return true if the downloaded archive is a .swc file or the +type+ argument is +:swc+.
  # @return [Boolean]
  def is_swc? archive, type=nil
    type == :swc || !archive.match(/\.swc$/).nil?
  end

  ##
  # Return true if the downloaded archive is a .rb file or the +type+ argument is +:rb+.
  # @return [Boolean]
  def is_rb? archive, type=nil
    type == :rb || !archive.match(/\.rb$/).nil?
  end

  private

  ##
  # Return true if the provided archive should be copied as-is, rather
  # than being unpacked first.
  # @return [Boolean]
  def is_copyable? archive
    (is_exe?(archive) || is_swc?(archive) || is_rb?(archive))
  end

  ##
  # Return true if the tgz should be unpacked.
  # @return [Boolean]
  def should_unpack_tgz? dir, clobber=nil
    return !directory_has_children?(dir) || clobber == :clobber

  end

  ##
  # Return true if the provided directory has one or more chidren.
  # @return [Boolean]
  def directory_has_children? dir
    (Dir.entries(dir) - ['.', '..']).size > 0
  end

  ##
  # @return [Boolean] true if the +archive+ and +destination+ exist.
  # @raise Sprout::Errors::ArchiveUnpackerError if the +archive+ or +destination+ don't exist.
  def validate archive, destination
    archive_message = "Archive could not be found at: #{archive}"
    raise Sprout::Errors::ArchiveUnpackerError.new(archive_message) unless valid_path?(archive)
    destination_message = "Destination could not be found at: #{destination}"
    raise Sprout::Errors::ArchiveUnpackerError.new(destination_message) unless valid_path?(destination)
    true
  end

  ##
  # @return [Boolean] true if the provided +path+ is not nil and exists on disk.
  def valid_path? path
    !path.nil? && File.exists?(path)
  end

  ##
  # Unpack an entry from a zip archive. This is an _inconvenience_ method
  # thanks to the way Ruby zip handles zip archives.
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
          raise Sprout::Errors::DestinationExistsError.new zip_dest_error.message
        end
      end
    end
  end
end

