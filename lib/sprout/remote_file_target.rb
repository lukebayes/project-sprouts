require 'digest/md5'

module Sprout

  class RemoteFileTarget < FileTarget

    attr_accessor :archive_type
    attr_accessor :url
    attr_accessor :md5

    def validate
      super
      raise Sprout::Errors::ValidationError.new "RemoteFileTarget.url is a required field" if url.nil?
      raise Sprout::Errors::ValidationError.new "RemoteFileTarget.md5 is a required field" if md5.nil?
      raise Sprout::Errors::ValidationError.new "RemoteFileTarget.archive_type is a required field" if archive_type.nil?
    end

    def resolve
      validate
      load_unpack_or_ignore_archive
      self
    end

    protected

    def expand_executable_path path
      # TODO: This is failing b/c it gets called before
      # we can set pkg_name and pkg_version - so join 
      # raises null pointer error.
      File.join unpacked_file, path
    end

    private

    ##
    # Do not cache this value...
    #
    # This response can change over time IF:
    #  - The downloaded bytes do not match the expected MD5
    #  - AND the user confirms the prompt that they are OK with this
    def downloaded_file
      File.join(Sprout.cache, pkg_name, "#{md5}.#{archive_type}")
    end

    def unpacked_file
      @unpacked_file ||= File.join(Sprout.cache, pkg_name, pkg_version)
    end

    def load_unpack_or_ignore_archive
      if(!unpacked_files_exist?)
        if(!File.exists?(downloaded_file))
          write_archive download_archive
        end

        bytes = File.read downloaded_file
        if should_unpack?(bytes, md5)
          unpack_archive
        end
      end
    end

    def unpacked_files_exist?
      File.exists?(unpacked_file) && !Dir.empty?(unpacked_file)
    end

    def download_archive
      Sprout::RemoteFileLoader.load url, pkg_name
    end

    def write_archive bytes
      FileUtils.mkdir_p File.dirname(downloaded_file)
      File.open downloaded_file, 'wb+' do |f|
        f.write bytes
      end
    end

    def should_unpack? bytes, expected_md5sum
      if expected_md5sum
        downloaded_md5 = Digest::MD5.new
        downloaded_md5 << bytes
        
        if(expected_md5sum != downloaded_md5.hexdigest)
          return prompt_for_md5_failure downloaded_md5, expected_md5sum
        end
      end
      return true
    end

    def prompt_for_md5_failure downloaded_md5, expected_md5sum
      puts "The MD5 Sum of the downloaded file (#{downloaded_md5.hexdigest}) does not match what was expected (#{expected_md5sum})."
      puts "Would you like to install anyway? [Yn]"
      user_response = $stdin.gets.chomp!
      if(user_response.downcase == 'y')
        return true
      else
        raise Sprout::Errors::RemoteFileLoaderError.new('MD5 Checksum failed')
      end
    end

    def unpack_archive
      FileUtils.mkdir_p unpacked_file
      unpacker = Sprout::ArchiveUnpacker.new
      unpacker.unpack downloaded_file, unpacked_file, archive_type
    end

  end
end

