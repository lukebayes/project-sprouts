
module Sprout
  class ZipUtil #:nodoc:

    # Pack up an archive from a directory on disk
    def self.pack(input, archive, excludes)
      Zip::ZipFile.open(archive, Zip::ZipFile::CREATE) do |zip|
        add_file_to_zip(zip, input, excludes)
      end
    end
    
    # Unpack an archive to a directory on disk
    def self.unpack(archive, destination)
      Zip::ZipFile.open(archive) do |zip|
        unpack_file(zip, destination)
      end
    end
    
    def self.unpack_file(zip, destination, path='')
      if(zip.file.file?(path))
        File.open(File.join(destination, path), 'w') do |dest|
          zip.file.open(path) do |src|
            dest.write src.read
          end
        end
      else
        Dir.mkdir(File.join(destination, path))
        zip.dir.foreach(path) do |dir|
          unpack_file(zip, destination, File.join(path, dir))
        end
      end
    end

    def self.add_file_to_zip(zip, path, excludes)
      if(File.directory?(path))
        zip.dir.mkdir(path)
        Dir.open(path).each do |child|
          if(!excluded?(child, excludes))
            add_file_to_zip(zip, File.join(path, child), excludes)
          end
        end
      else
        File.open(path) do |src|
          zip.file.open(path, 'w') do |dest|
            dest.write src.read
          end
        end
      end
    end

    def self.excluded?(str, excludes)
      excludes.each do |exc|
        if(str == exc)
          return true
        end
      end
      return false
    end

  end
end