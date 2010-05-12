require 'digest/md5'

module Sprout

  class RemoteFileLoader #:nodoc:

    class << self
    
      def load uri, md5, filename=nil, force=false
        response = fetch uri.to_s, filename
        if(force || response_is_valid?(response, md5))
          return response
        end
        nil
      end

      private
      
      def response_is_valid? response, expected_md5sum
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
              raise Sprout::Errors::RemoteFileLoaderError.new('MD5 Checksum failed')
            end
          end
        end
        return true
      end
      
      def fetch uri, name=nil
        uri = URI.parse(uri)
        progress = nil
        response = nil
        name ||= uri.path.split("/").pop
        
        raise Sprout::Errors::RemoteFileLoaderError.new("The RemoteFileTask failed for #{name}. We can only handle HTTP requests at this time, it seems you were trying: '#{uri.scheme}'") if uri.scheme != 'http'
        begin
          open(uri.to_s, :content_length_proc => lambda {|t|
            if t && t > 0
              progress = Sprout::ProgressBar.new(name, t)
              progress.file_transfer_mode
              progress.set(0)
            else
              progress = Sprout::ProgressBar.new(name, 0)
              progress.file_transfer_mode
              progress.set(0)
            end
          },
          :progress_proc => lambda {|s|
            progress.set s if progress
          }) do |f|
            response = f.read
            progress.finish
          end
        rescue SocketError => sock_err
          raise Sprout::Errors::RemoteFileLoaderError.new("[ERROR] #{sock_err.to_s}")
        rescue OpenURI::HTTPError => http_err
          raise Sprout::Errors::RemoteFileLoaderError.new("[ERROR] Failed to load file from: '#{uri.to_s}'\n[REMOTE ERROR] #{http_err.io.read.strip}")
        rescue Errno::ECONNREFUSED => econ_err
          raise Errno::ECONNREFUSED.new("[ERROR] Connection refused at: '#{uri.to_s}'")
        end

        return response
      end

    end
  end
end

