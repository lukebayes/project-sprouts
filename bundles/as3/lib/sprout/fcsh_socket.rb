require 'socket'
require 'sprout/fcsh_service'

module Sprout #:nodoc

  class FCSHSocket

    def self.server(port=12321, out=nil)
      out = out || $stdout
      server = TCPServer.new(port)
      @fcsh = FCSHService.new(out)
      out.puts ">> fcsh started, waiting for connections on port #{port}"
      while(session = server.accept)
        response = @fcsh.execute(session.gets)
        session.puts(response)
        session.flush
        session.close
      end
    end
    
    def self.execute(command, port=12321)
      session = TCPSocket.new('localhost', port)
      session.puts(command)
      response = session.read
      
      error = response =~ /(.*Error:.*\^.*)\n/m
      if(error)
        raise FCSHError.new(response)
      end
      
      session.close
      return response
    end

  end
end
