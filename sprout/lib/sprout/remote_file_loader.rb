
module Sprout
  class RemoteFileLoaderError < StandardError #:nodoc:
  end

  class RemoteFileLoader #:nodoc:
    
    def get_remote_file(uri, target, archive_type=nil, force=false, md5=nil)
      @archive_type = archive_type
      puts "get remote file with: #{uri} and target: #{target}"

      if(force || !File.exists?(target))
        response, name = fetch(uri.to_s)
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
          name = f.base_uri.path.split("/").pop
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

      return response, name
    end
    
  end
end
