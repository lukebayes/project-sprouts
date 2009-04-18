
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
      unpacked = unpacked_file_name(file_name, dir)
      puts ">> unpack_archive with: #{unpacked}"
      if(File.exists?(unpacked) && force)
        FileUtils.rm_rf(unpacked)
      end
      
      if(!File.exists?(unpacked))
        if(is_zip?(file_name, archive_type))
          unpack_zip(file_name, dir)
        elsif(is_targz?(file_name, archive_type))
          unpack_targz(file_name, dir)
        elsif(is_dmg?(file_name, archive_type))
          unpack_dmg(file_name, dir)
        elsif(is_swc?(file_name, archive_type))
          # just copy the swc...
        elsif(is_rb?(file_name, archive_type))
          return
        elsif(is_exe?(file_name, archive_type))
          FileUtils.mkdir_p(dir)
          File.mv(file_name, dir)
        else
          raise RemoteFileLoaderError.new("RemoteFileTask does not know how to unpack files of type: #{file_name}")
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
            puts ">> [ZIP ERROR ENCOUNTERED] trying again with: #{dir}"
            FileUtils.makedirs(dir)
            retry
          end
          raise err
        end
      end
    end
    
    def unpacked_file_name(file, dir)
      basename = File.basename(file)
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
        if(child != tgz_file)
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
      rescue
        if(File.exists?(full_mounted_path))
          system("hdiutil unmount -force \"#{full_mounted_path}\"")
        end
      end
    end
    
    def is_exe?(file, archive_type=nil)
      return (archive_type == :exe || file.split('.').pop == 'exe')
    end
    
    def is_zip?(file, archive_type=nil)
      return (archive_type == :zip || file.split('.').pop == 'zip')
    end
    
    def is_targz?(file, archive_type=nil)
      parts = file.split('.')
      part = parts.pop
      return archive_type == :targz || (part == 'tgz' || part == 'gz' && parts.pop == 'tar')
    end
    
    def is_gzip?(file, archive_type=nil)
      return archive_type == :gzip || (file.split('.').pop == 'gz')
    end
    
    def is_swc?(file, archive_type=nil)
      return archive_type == :swc || (file.split('.').pop == 'swc')
    end
    
    def is_rb?(file, archive_type=nil)
      return archive_type == :rb || (file.split('.').pop == 'rb')
    end
    
    def is_dmg?(file, archive_type=nil)
      return archive_type == :dmg || (file.split('.').pop == 'dmg')
    end    
  end
end
