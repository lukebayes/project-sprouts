
module Sprout
  class RemoteFileLoaderError < StandardError #:nodoc:
  end
  
  class RemoteFileLoader #:nodoc:
    include Archive::Tar
    
    def get_remote_file(uri, target, force=false, md5=nil)
      if(force || !File.exists?(target))
        response = fetch(uri.to_s)
        if(response_is_valid?(response, md5))
          write(response, target, force)
        end
      end
    end
    
    def response_is_valid?(response, expected_md5sum=nil)
      if(expected_md5sum)
        md5 = Digest::MD5.new
        md5 << response
        
        if(expected_md5sum != md5.hexdigest)
          puts "The MD5 Sum of the downloaded file (#{md5.hexdigest}) does not match what was expected (#{expected_md5sum})."
          puts "Would you like to install anyway? [Yn]"
          response = $stdin.gets.chomp!
          if(response.downcase == 'y')
            return true
          else
            raise RemoteFileLoaderError.new('MD5 Checksum failed')
          end
        end
      end
      return true
    end
    
    def write(response, target, force=false)
      FileUtils.makedirs(File.dirname(target))
      if(force && File.exists?(target))
        File.delete(target)
      end
      File.open(target, 'wb') do |f|
        f.write(response)
      end
    end
    
    def fetch(uri)
      uri = URI.parse(uri)
      # Download the file now to the downloads dir
      # If the file is an archive (zip, gz, tar, tar.gz, dmg), extract to
      # Sprouts/cache/@type/@name
      # Check the location again...
      progress = nil
      response = nil
      name = uri.path.split("/").pop
      
      raise RemoteFileLoaderError.new("The RemoteFileTask failed for #{name}. We can only handle HTTP requests at this time, it seems you were trying: '#{uri.scheme}'") if uri.scheme != 'http'
      begin
        open(uri.to_s, :content_length_proc => lambda {|t|
          if t && t > 0
            progress = ProgressBar.new(name, t)
            progress.file_transfer_mode
            progress.set(0)
          else
            progress = ProgressBar.new(name, 0)
            progress.file_transfer_mode
            progress.set(0)
          end
        },
        :progress_proc => lambda {|s|
          progress.set s if progress
        }) {|f|
          response = f.read
          progress.finish
        }
      rescue SocketError => sock_err
        raise RemoteFileLoaderError.new("[ERROR] #{sock_err.to_s}")
      rescue OpenURI::HTTPError => http_err
        raise RemoteFileLoaderError.new("[ERROR] Failed to load file from: '#{uri.to_s}'\n[REMOTE ERROR] #{http_err.io.read.strip}")
      rescue Errno::ECONNREFUSED => econ_err
        raise Errno::ECONNREFUSED.new("[ERROR] Connection refused at: '#{uri.to_s}'")
      end

      return response
    end
    
    def unpack_downloaded_file(file_name, dir)
      if(!File.exists?(dir))
        if(is_zip?(file_name))
          unpack_zip(file_name, dir)
        elsif(is_targz?(file_name))
          unpack_targz(file_name, dir)
        elsif(is_dmg?(file_name))
          unpack_dmg(file_name, dir)
        elsif(is_swc?(file_name))
          # just copy the swc...
        elsif(is_rb?(file_name))
          return
        elsif(is_exe?(file_name))
          FileUtils.mkdir_p(dir)
          File.mv(file_name, dir)
        else
          raise UsageError.new("RemoteFileTask does not know how to unpack files of type: #{file_name}")
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
          #puts ">> zip_dir: #{zip_dir} zip_name: #{zip_name} output: #{output}"
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
    
    def is_exe?(file)
      return (file.split('.').pop == 'exe')
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
  end
end
