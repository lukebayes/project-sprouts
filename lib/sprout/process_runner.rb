
module Sprout #:nodoc:

  class ProcessRunnerError < StandardError # :nodoc:
  end
  
  # The ProcessRunner is a cross-platform wrapper for executing
  # external executable processes.
  #
  # As it turns out, Ruby handle differences very well, and 
  # other process libraries (like win32-open3 and open4.popen4),
  # do make the experience more consistent on a given platform,
  # but they don't hide the differences introduced by the 
  # continuing beligerence of Windows or *nix (depending on 
  # which side of the fence you're on).
  class ProcessRunner
    attr_reader :pid,
                :r,
                :w,
                :e
    
    # Execute the provided command using the open4.popen4
    # library. This is generally only used by Cygwin and
    # *nix variants (including OS X).
    def execute_open4 *command
      execute_with_block *command do
        open4_popen4_block *command
      end
    end
    
    # Execute the provided command using the win32-open3
    # library. This is generally used even by 64-bit
    # Windows installations.
    def execute_win32(*command)
      execute_with_block *command do
        win32_open3_block *command
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

    private

    def open4_popen4_block *command
      require 'open4'
      @pid, @w, @r, @e = open4.popen4(*command)
    end

    def win32_open3_block *command
      gem 'win32-open3', '0.2.5'
      require 'win32/open3'
      Open3.popen3(*command) do |w, r, e, pid|
            @w = w
            @r = r
            @e = e
            @pid = pid
      end
    end

    def execute_with_block *command
      begin
        @alive = true
        yield 
      rescue Errno::EACCES => e
        update_executable_mode(*command)
        yield
      rescue Errno::ENOENT => e
        @alive = false
        part = command[0].split(' ').shift
        raise ProcessRunnerError.new("The expected executable was not found for command [#{part}], please check your system path and/or sprout definition")
      end
    end

    def update_executable_mode(*command)
      str = command.shift
      if(File.exists?(str))
        FileUtils.chmod(0744, str)
      end
    end
    
  end
end

