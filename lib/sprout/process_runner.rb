
module Sprout

  # The ProcessRunner is a cross-platform wrapper for executing
  # external executable processes.
  #
  # This class is typically accesses via the concrete Sprout::System
  # classes in order to avoid ugly branching logic in the application
  # layer.
  #
  # An example of this kind of usage might be:
  #
  #   Sprout.current_system.execute './some.exe', '--foo=bar --baz=buz'
  #
  # To use this class directly, you need to know if you're on
  # a unix-like system or a dos platform as these two deal with
  # processes very differently.
  #
  # Assuming you know you're on a unix-like system, you could
  # execute the previous example with:
  #
  #   runner = Sprout::ProcessRunner.new
  #   runner.execute_open4 './some.exe --foo-bar --baz=buz'
  #   puts runner.read
  #
  class ProcessRunner

    attr_reader :pid
    attr_reader :ruby_version

    ##
    # @return [IO] Read only
    attr_reader :r

    ##
    # @return [IO] Write only
    attr_reader :w

    ##
    # @return [IO] Error output
    attr_reader :e

    def initialize
      super
      @ruby_version = RUBY_VERSION
    end
    
    ##
    # Execute the provided command using the open4.popen4
    # library. This is generally only used by Cygwin and
    # *nix variants (including OS X).
    def execute_open4 *command
      execute_with_block *command do
        # Not sure about the join - with the 1.0 push, we're
        # sending in 2 args - the exe path, and options as a string.
        # This was new and was causing problems...
        @pid, @w, @r, @e = open4_popen4_block *command.join(' ')
      end
    end
    
    ##
    # Execute the provided command using the win32-open3
    # library. This is generally used only only Windows
    # systems (even 64 bit).
    def execute_win32(*command)
      execute_with_block *command do
        @pid, @w, @r, @e = io_popen_block *command.join(' ')
      end
    end

    ##
    # @return [Boolean] whether the process is still running.
    def alive?
      @alive = update_status
    end
    
    ##
    # Kill the process.
    def kill
      Process.kill(9, pid)
    end
    
    ##
    # Close the process
    def close
      update_status
    end
    
    ##
    # Send an update signal to the process.
    def update_status
      pid_int = Integer("#{ @pid }")
      begin
        Process::kill 0, pid_int
        true
      rescue Errno::ESRCH
        false
      end
    end
    
    ##
    # Read +count+ characters from the process standard out.
    #
    # @param count [Integer] Number of characters to read.
    # @return [String]
    def readpartial count
      @r.readpartial count
    end
    
    ##
    # Read +count+ lines from the process standard out.
    #
    # @param count [Integer] Number of lines to read.
    # @return [String]
    def readlines count
      @r.readlines count
    end
    
    ##
    # Flush the write IO to the process.
    def flush
      @w.flush
    end
    
    ##
    # Get user input on the read stream from the process.
    def getc
      @r.getc
    end
    
    ##
    # Print some characters to process without an end of line character.
    def print msg
      @w.print msg
    end
    
    ##
    # Print characters to the process followed by an end of line.
    def puts(msg)
      @w.puts(msg)
    end
    
    ##
    # Close the write stream - usually terminates the process.
    def close_write
      @w.close_write
    end
    
    ##
    # Wait for the process to end and return the entire standard output.
    def read
      return @r.read
    end
    
    ##
    # Wait for the process to end and return the entire standard error.
    def read_err
      return @e.read
    end

    def readpartial_err count
      return @e.readpartial count
    end

    private

    def open4_popen4_block *command
      require 'open4'
      open4.popen4(*command)
    end

    def io_popen_block *command
      if(ruby_version == '1.8.6' || ruby_version == '1.8.7')
        win32_open3_block *command
      else
        open3_popen3_block *command
      end
    end

    def open3_popen3_block *command
      require 'open3'
      write, read, error, wait_thread = Open3.popen3(*command)
      [wait_thread[:pid], write, read, error]
    end

    def win32_open3_block *command
      write, read, error, pid = nil
      gem 'win32-open3'
      require 'win32/open3'
      Open3.popen3(*command) do |w, r, e, p|
            pid   = p
            write = w
            read  = r
            error = e
      end
      [pid, write, read, error]
    end

    def execute_with_block *command
      begin
        @alive = true
        yield 
      rescue Errno::EACCES => eacces
        update_executable_mode(*command)
        yield
      rescue Errno::ENOENT => enoent
        @alive = false
        part = command[0]
        raise Sprout::Errors::ProcessRunnerError.new("The expected executable was not found for command [#{part}], please check your system path and/or sprout definition")
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

