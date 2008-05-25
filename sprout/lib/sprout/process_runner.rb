
module Sprout #:nodoc:
  class ProcessRunnerError < StandardError # :nodoc:
  end
  
  class ProcessRunner #:nodoc:
    attr_reader :pid,
                :r,
                :w,
                :e
    
    def initialize(*command)
      @command = command
      begin
        usr = User.new()
        if(usr.is_a?(WinUser) && !usr.is_a?(CygwinUser))
          require 'win32/open3'
          Open3.popen3(*@command) do |w, r, e, pid|
          	@w = w
          	@r = r
          	@e = e
          	@pid = pid
          end
        else
          require 'open4'
          @pid, @w, @r, @e = open4.popen4(*@command)
        end
      rescue Errno::ENOENT => e
        part = command[0].split(' ').shift
        raise ProcessRunnerError.new("The expected executable was not found for command [#{part}], please check your system path and/or sprout definition")
      end
    end
    
    def readpartial(count)
      @r.readpartial(count)
    end
    
    def readlines
      @r.readlines
    end
    
    def flush
      @w.flush
    end
    
    def getc
      @r.getc
    end
    
    def print(msg)
      @w.print msg
    end
    
    def puts(msg)
      @w.puts(msg)
    end
    
    def read
      return @r.read
    end
    
    def read_err
      return @e.read
    end
  end
end
