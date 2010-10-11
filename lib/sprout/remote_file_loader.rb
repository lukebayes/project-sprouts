
module Sprout

  ##
  # This class is used to load remote files from the network.
  class RemoteFileLoader

    class << self
    
      def load uri, md5=nil, display_name=nil
        fetch uri.to_s, display_name
      end

      private
      
      def fetch uri, display_name=nil
        begin
          return open_uri uri, display_name
        rescue SocketError => sock_err
          raise Sprout::Errors::RemoteFileLoaderError.new("[ERROR] Failed to load file from: '#{uri.to_s}' - Please check that your machine has a connection to the internet.\n[REMOTE ERROR] #{sock_err.to_s}")
        rescue OpenURI::HTTPError => http_err
          raise Sprout::Errors::RemoteFileLoaderError.new("[ERROR] Failed to load file from: '#{uri.to_s}'\n[REMOTE ERROR] #{http_err.io.read.strip}")
        rescue Errno::ECONNREFUSED => econ_err
          raise Errno::ECONNREFUSED.new("[ERROR] Connection refused at: '#{uri.to_s}'")
        end
      end

      private

      def open_uri uri, display_name=nil
        uri = URI.parse(uri)
        progress = nil
        response = nil
        display_name ||= uri.path.split("/").pop
        
        # Why was this here? Shouldn't the 'open' command work for other
        # protocols like https?
        #
        #message = "The RemoteFileTask failed for #{display_name}. We can only handle HTTP requests at this time, it seems you were trying: '#{uri.scheme}'"
        #raise Sprout::Errors::RemoteFileLoaderError.new(message) if uri.scheme != 'http' || uri.scheme != 'https'

        # This is the strangest implementation I've seen in Ruby yet.
        # Double lambda arguments with a block to top it off?! Gawsh.
        open(uri.to_s, 
          :content_length_proc => lambda {|length|
            length ||= 0
            progress = Sprout::ProgressBar.new(display_name, length)
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

    end
  end
end

