require 'rubygems/digest/md5'

module Sprout

  ##
  # This class is used to load remote files from the network.
  class RemoteFileLoader

    class << self
    
      def load uri, md5=nil, filename=nil, force=false
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
            return prompt_for_md5_failure md5, expected_md5sum
          end
        end
        return true
      end
      
      def fetch uri, name=nil
        begin
          return open_uri uri, name
        rescue SocketError => sock_err
          raise Sprout::Errors::RemoteFileLoaderError.new("[ERROR] #{sock_err.to_s}")
        rescue OpenURI::HTTPError => http_err
          raise Sprout::Errors::RemoteFileLoaderError.new("[ERROR] Failed to load file from: '#{uri.to_s}'\n[REMOTE ERROR] #{http_err.io.read.strip}")
        rescue Errno::ECONNREFUSED => econ_err
          raise Errno::ECONNREFUSED.new("[ERROR] Connection refused at: '#{uri.to_s}'")
        end
      end

      private

      def open_uri uri, name=nil
        uri = URI.parse(uri)
        progress = nil
        response = nil
        name ||= uri.path.split("/").pop
        
        # Why was this here? Shouldn't the 'open' command work for other
        # protocols like https?
        #
        #message = "The RemoteFileTask failed for #{name}. We can only handle HTTP requests at this time, it seems you were trying: '#{uri.scheme}'"
        #raise Sprout::Errors::RemoteFileLoaderError.new(message) if uri.scheme != 'http' || uri.scheme != 'https'

        # This is the strangest implementation I've seen in Ruby yet.
        # Double lambda arguments with a block to top it off?! Gawsh.
        open(uri.to_s, 
          :content_length_proc => lambda {|length|
            length ||= 0
            progress = Sprout::ProgressBar.new(name, length)
            progress.file_transfer_mode
            progress.set(0)
          },
          :progress_proc => lambda {|length|
            progress.set length if progress
        }) do |f|
          response = f.read
          progress.finish
        end

        response
      end

      def prompt_for_md5_failure md5, expected_md5sum
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
  end
end

