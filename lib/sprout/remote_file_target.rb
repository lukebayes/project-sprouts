
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

    private

    def downloaded_file
      @downloaded_file ||= File.join(Sprout.cache, pkg_name, md5)
    end

    def unpacked_file
      @unpacked_file ||= File.join(Sprout.cache, pkg_name, pkg_version)
    end

    def load_unpack_or_ignore_archive
      if(!File.exists?(unpacked_file))
        if(!File.exists?(downloaded_file))
          write_archive download_archive
        end
        unpack_archive
      end
    end

    def download_archive
      puts "resolving #{url} to: #{Sprout.cache}"
      #bytes = Sprout::RemoteFileLoader.load(url, md5, pkg_name)
    end

    def write_archive bytes
      FileUtils.mkdir_p File.dirname(downloaded_file)
      File.open downloaded_file, 'w+' do |f|
        f.write bytes
      end
    end

    def unpack_archive
      FileUtils.mkdir_p unpacked_file
      unpacker = Sprout::ArchiveUnpacker.new
      unpacker.unpack downloaded_file, unpacked_file, archive_type
    end

  end
end

