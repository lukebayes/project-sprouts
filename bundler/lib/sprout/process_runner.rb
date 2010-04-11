
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
        @alive = true
        usr = User.new()
        if(usr.is_a?(WinUser) && !usr.is_a?(CygwinUser))
          gem 'win32-open3', '0.2.5'
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
      rescue Errno::EACCES => e
        update_executable_mode(*@command)
        @pid, @w, @r, @e = open4.popen4(*@command)
      rescue Errno::ENOENT => e
        @alive = false
        part = command[0].split(' ').shift
        raise ProcessRunnerError.new("The expected executable was not found for command [#{part}], please check your system path and/or sprout definition")
      end
    end
    
    def update_executable_mode(*command)
      parts = command.join(' ').split(' ')
      str = parts.shift
      while(parts.size > 0)
        if(File.exists?(str))
          FileUtils.chmod(744, str)
          return
        else
          str << " #{parts.shift}"
        end
      end
    end
    
    def alive?
      @alive = update_status
    end
    
    def kill
      Process.kill(9, pid)
    end
    
    def close
      update_status
    end
    
    def update_status
      pid_int = Integer("#{ @pid }")
      begin
        Process::kill 0, pid_int
        true
      rescue Errno::ESRCH
        false
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
    
    def close_write
      @w.close_write
    end
    
    def read
      return @r.read
    end
    
    def read_err
      return @e.read
    end
  end
end

