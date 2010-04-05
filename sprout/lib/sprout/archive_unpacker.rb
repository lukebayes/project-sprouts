
module Sprout
  class ArchiveUnpackerError < StandardError #:nodoc:
  end

  # Unpack downloaded files from a variety of common archive types.
  # This library should efficiently extract archived files
  # on OS X, Win XP, Vista, DOS, Cygwin, and Linux.
  # 
  # It will attempt to infer the archive type by standard mime-type file
  # extensions, but if there is a file with no extension, the unpack_archive
  # method can be provided with an @archive_type symbol argument that is one
  # of the following values:
  #   :exe
  #   :zip
  #   :targz
  #   :gzip
  #   :swc
  #   :rb
  #   :dmg
  class ArchiveUnpacker #:nodoc:
    include Archive::Tar
    
    def unpack_archive(file_name, dir, force=false, archive_type=nil)
      archive_type ||= inferred_archive_type(file_name)
      suffix = suffix_for_archive_type(archive_type)
      
      unpacked = unpacked_file_name(file_name, dir, suffix)
      if(File.exists?(unpacked) && force)
        FileUtils.rm_rf(unpacked)
      end
      
      if(!File.exists?(unpacked))
        case archive_type.to_s
          when 'zip'
            unpack_zip(file_name, dir)
          when 'targz'
            unpack_targz(file_name, dir)
          when 'dmg'
            unpack_dmg(file_name, dir)
          when 'exe'
            FileUtils.mkdir_p(dir)
            File.move(file_name, dir)
          when 'swc' || 'rb'
            return
          else
            raise ArchiveUnpackerError.new("ArchiveUnpacker does not know how to unpack files of type: #{archive_type} for file_name: #{file_name}")
        end
      end
    end
    
    def unpack_zip(zip_file, dir)
      # Avoid the rubyzip Segmentation Fault bug
      # at least on os x...
      if(RUBY_PLATFORM =~ /darwin/)
          # Unzipping on OS X
          FileUtils.makedirs(dir)
          zip_dir = File.expand_path(File.dirname(zip_file))
          zip_name = File.basename(zip_file)
          output = File.expand_path(dir)
          # puts ">> zip_dir: #{zip_dir} zip_name: #{zip_name} output: #{output}"
          %x(cd #{zip_dir};unzip #{zip_name} -d #{output})
      else
        retries = 0
        begin
          retries += 1
          Zip::ZipFile::open(zip_file) do |zf|
            zf.each do |e|
              fpath = File.join(dir, e.name)
              FileUtils.mkdir_p(File.dirname(fpath))
              # Disgusting, Gross Hack to fix DOS/Ruby Bug
              # That makes the zip library throw a ZipDestinationFileExistsError
              # When the zip archive includes two files whose names 
              # differ only by extension.
              # This bug actually appears in the File.exists? implementation
              # throwing false positives!
              # If you're going to use this code, be sure you extract
              # into a new, empty directory as existing files will be 
              # clobbered...
              begin
                if(File.exists?(fpath) && !File.directory?(fpath))
                  hackpath = fpath + 'hack'
                  zf.extract(e, hackpath)
                  File.copy(hackpath, fpath)
                  File.delete(hackpath)
                else
                  zf.extract(e, fpath)
                end
              rescue NotImplementedError => ni_err
                puts "[WARNING] #{ni_err} for: #{e}"
              end
            end
          end
        rescue StandardError => err
          FileUtils.rm_rf(dir)
          if(retries < 3)
            FileUtils.makedirs(dir)
            retry
          end
          raise err
        end
      end
    end
    
    def unpacked_file_name(file, dir, suffix=nil)
      basename = File.basename(file, suffix)
      path = File.expand_path(dir)
      return File.join(path, basename)
    end
    
    def unpack_targz(tgz_file, dir)
      if(!File.exists?(dir))
        FileUtils.makedirs(dir)
      end
      tar = Zlib::GzipReader.new(File.open(tgz_file, 'rb'))
      Minitar.unpack(tar, dir)
      
      # Recurse and unpack gzipped children (Adobe did this double 
      # gzip with the Linux FlashPlayer for some reason)
      Dir.glob("#{dir}/**/*.tar.gz").each do |child|
        if(child != tgz_file && dir != File.dirname(child))
          unpack_targz(child, File.dirname(child))
        end
      end
      
    end
    
    # This is actually not unpacking the FlashPlayer
    # Binary file as expected...
    # OSX is treated the player binary as if it is
    # a regular text file, but if it is copied manually,
    # the command works fine!?
    def unpack_dmg(dmg_file, dir)
      # 1) Mount the dmg in place
      # 2) Recursively Copy its contents to asproject_home
      # 3) Unmount the dmg
      if(mounted_path.nil?)
        raise StandardError.new('DMG file downloaded, but the RemoteFileTask needs a mounted_path in order to mount it')
      end

      if(!File.exists?(full_mounted_path))
        system("hdiutil mount #{dmg_file}")
      end
      
      begin
        mounted_target = File.join(full_mounted_path, extracted_file)
  
        # Copy the DMG contents using system copy rather than ruby utils
        # Because OS X does something special with .app files that the
        # Ruby FileUtils and File classes break...
        from = mounted_target
#        from = File.join(full_mounted_path, extracted_file)
        to = File.join(@user.downloads, @name.to_s, extracted_file)
        FileUtils.makedirs(File.dirname(to))
        
        if(File.exists?(from))
          `ditto '#{from}' '#{to}'`
        end
      rescue StandardError => e
        if(File.exists?(full_mounted_path))
          system("hdiutil unmount -force \"#{full_mounted_path}\"")
        end
      end
    end
    
    def suffix_for_archive_type(type)
      if(type == :targz)
        return '.tar.gz'
      else
        return ".#{type.to_s}"
      end
    end
    
    def inferred_archive_type(file_name)
      if is_zip?(file_name)
        return :zip
      elsif is_targz?(file_name)
        return :targz
      elsif is_gzip?(file_name)
        return :gz
      elsif is_swc?(file_name)
        return :swc
      elsif is_rb?(file_name)
        return :rb
      elsif is_dmg?(file_name)
        return :dmg
      elsif is_exe?(file_name)
        return :exe
      else
        return nil
      end
      
    end
    
    def is_zip?(file)
      return (file.split('.').pop == 'zip')
    end
    
    def is_targz?(file)
      parts = file.split('.')
      part = parts.pop
      return (part == 'tgz' || part == 'gz' && parts.pop == 'tar')
    end
    
    def is_gzip?(file)
      return (file.split('.').pop == 'gz')
    end
    
    def is_swc?(file)
      return (file.split('.').pop == 'swc')
    end
    
    def is_rb?(file)
      return (file.split('.').pop == 'rb')
    end
    
    def is_dmg?(file)
      return (file.split('.').pop == 'dmg')
    end    

    def is_exe?(file)
      return (file.split('.').pop == 'exe')
    end
  end
end
