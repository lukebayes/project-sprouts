
module Sprout
  class RemoteFileTargetError < StandardError #:nodoc:
  end

  class RemoteFileTarget # :nodoc:

    attr_writer   :archive_path
    
    # The user path where this gem will download and install files
    # This value is set by the Sprout::Builder that creates this RemoteFileTarget
    attr_accessor :install_path

    # Optional md5 hash, usually set in the sprout.spec for each RemoteFileTarget
    # If this value is set, the downloaded archive will be hashed, the hashes will
    # be compared and if they differ, the installation process will break.
    attr_accessor :md5

    # Used for dmg archives. Absolute path to the mounted dmg (essentially its name)
    attr_accessor :mount_path

    # Which platform will this RemoteFileTarget support.
    # Supported options are:
    #  * universal
    #  * macosx
    #  * win32
    #  * linux
    attr_accessor :platform

    # URL where Sprouts can go to download the RemoteFileTarget archive
    attr_accessor :url
    
    # If the archive type cannot be assumed from the returned file name,
    # it must be provided as one of the following:
    #   :exe
    #   :zip
    #   :targz
    #   :gzip
    #   :swc
    #   :rb
    #   :dmg
    # @see ArchiveUnpacker
    attr_accessor :archive_type

    # Relative path within the archive to the executable or binary of interest
    def archive_path
      @archive_path ||= ''
    end

    # Resolve this RemoteFileTarget now. This method is called by the Sprout::Builder
    # and will download, install and unpack the described archive, unless it is
    # already installed
    def resolve(update=false)
      # Wanted to raise, but it seems we support RemoteFileTargets that are actually self-installed binaries...
      # like SWFMill on Linux. @see the BuilderTest.test_build_no_install for more info.
      # raise RemoteFileTargetError.new('Cannot retrieve a RemoteFileTarget without a url') if url.nil?
      return if url.nil?
      
      if(url && (update || !File.exists?(downloaded_path)))
        content = download(url, update)
        FileUtils.mkdir_p(File.dirname(downloaded_path))

        FileUtils.touch(downloaded_path)
        File.open(downloaded_path, 'r+') do |file|
          file.write(content)
        end
      end

      if(!File.exists?(installed_path) || !File.exists?(File.join(installed_path, archive_path) ))
        archive_root = File.join(install_path, 'archive')
        install(downloaded_path, archive_root, update, archive_type)
      end
    end
    
    # Return the basename of the executable that this RemoteFileTarget refers to
    def executable
      return File.basename(archive_path)
    end
    
    # The root path to the unpacked archive files. This is the base path that will be added to any
    # +archive_path+ relative paths
    def installed_path
      @installed_path ||= File.join(install_path, 'archive')
      return @installed_path
    end
    
    # Parent directory where archives are downloaded
    # can be something like: ~/Library/Sprouts/cache/0.7/sprout-somesprout-tool.x.x.x/
    def downloaded_path
      @downloaded_path ||= File.join(install_path, file_name(url))
      return @downloaded_path
    end
    
    # Base file name represented by the provided +url+
    # Will strip off any ? arguments and trailing slashes. May not play nice with Rails URLS,
    # We expect archive file name suffixes like, zip, gzip, tar.gz, dmg, etc.
    def file_name(url=nil)
      url ||= self.url
      
      url = url.split('?').shift
      
      parts = url.split('/')
      if(parts.last == '/')
        parts.pop
      end
      
      file = parts.pop

      if(!archive_type.nil? && file.match(/\.#{archive_type.to_s}$/).nil?)
        file << ".#{archive_type.to_s}"
      end
      
      return file
    end
    
    private
    def download(url, update=false)
      loader = RemoteFileLoader.new
      loader.get_remote_file(url, update, md5)
    end
    
    def install(from, to, force, archive_type=nil)
      unpacker = ArchiveUnpacker.new
      unpacker.unpack_archive(from, to, force, archive_type)
    end
    
  end
end
