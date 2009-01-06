
module Sprout #:nodoc:
  
  class FDBTaskError < StandardError #:nodoc:
  end

  # The FDBTask provides a procedural rake front end to the FDB command line tool
  # 
  # Here is a decent tutorial on using FDB with SWF or HTML content:
  # http://installingcats.wordpress.com/tag/adobe-flex/
  #
  # You can send the fdb task some debug commands directly or simply
  # execute the rake task and interact with the debugger manually.
  #
  # The FDBTask requires that you have a debug Flash Player installed
  # on your system as the default execution application for SWF files.
  #
  # Following is an example of setting up a breakpoint in
  # SomeFile at line 23
  #   fdb :debug do |t|
  #     t.file = 'bin/SomeProject-debug.swf'
  #     t.run
  #     t.break = 'SomeFile:23'
  #     t.continue
  #   end
  #
  # You can also point the FDBTask at HTML pages. These pages will be 
  # launched in your default browser. You will need to manually install
  # a debug Flash Player in that particular browser.
  # 
  # To use a browser instead of the desktop Flash Player, simply point the
  # file argument at an HTML document or remote URL. The SWF file loaded
  # must be compiled using the -debug flag, and executed in a debug Flash Player
  # in order to connect to properly connect to the debugger.
  #   fdb :debug do |t|
  #     t.file = 'bin/SomeProject-debug.html'
  #     t.run
  #     t.continue
  #   end
  #
  class FDBTask < ToolTask
    TEST_RESULT_PRELUDE = '<XMLResultPrinter>'
    TEST_RESULT_CLOSING = '</XMLResultPrinter>'
    TEST_RESULT_FILE    = 'AsUnitResults.xml'
    
    # Relative or absolute path to where unit test results
    # should be written to disk.
    # This field can be used in conjunction with the AsUnit
    # XMLResultPrinter which will trace out JUnit style XML 
    # test results.
    # By telling fdb where to write those test results, it
    # will scan the trace output stream looking for +test_result_prelude+,
    # and +test_result_closing+. Once the closing is encountered, the
    # prelude and closing (and everything in between) will be written
    # to disk in the file identified by +test_result_file+, and fdb
    # will be closed down.
    attr_writer :test_result_file

    # String that indicates the beginning of printable test results
    # Default value is '<XMLResultPrinter>'
    attr_writer :test_result_prelude

    # String that indicates the closing of printable test results
    # Default value is '</XMLResultPrinter>'
    # See test_result_prelude for more info.
    attr_writer :test_result_closing

    # Boolean value that tells fdb whether or not it should automatically
    # shut down when an exception is encountered. This feature is used to
    # prevent GUI prompts for unhandled exceptions, especially when running
    # a test harness under a continuous integration tool - like cruise control.
    # If an exception is encountered, fdb will automatically print the exception,
    # a full stack trace and all local variables in the function where the failure 
    # occured.
    attr_writer :kill_on_fault

    def initialize_task # :nodoc:
      @default_gem_name = 'sprout-flex3sdk-tool'
      @default_gem_path = 'bin/fdb'
      @kill_on_fault = false
      @queue = []
    end

    def define # :nodoc:
      super
      CLEAN.add(test_result_file)
      self
    end
    
    def stdout=(out) # :nodoc:
      @stdout = out
    end
    
    def stdout # :nodoc:
      @stdout ||= $stdout
    end
    
    def validate_swf(swf)
      # TODO: Ensure the SWF has been compiled with debugging
      # turned on.
      # I believe this will require actually parsing the SWF file and
      # scanning for the EnableDebugger2 tag.
      # http://www.adobe.com/devnet/swf/pdf/swf_file_format_spec_v9.pdf
    end
    
    def execute(*args) # :nodoc:
      # Ensure that if we load a SWF it's been compiled with debugging turned on!
      file_name = @file

      if(file_name.match(/\.swf$/))
        validate_swf(file_name)
      end

      buffer = FDBBuffer.new(get_executable, stdout)
      buffer.wait_for_prompt
      buffer.test_result_file = test_result_file
      buffer.test_result_prelude = test_result_prelude
      buffer.test_result_closing = test_result_closing
      buffer.kill_on_fault = kill_on_fault?

      @queue.each do |command|
        handle_command(buffer, command)
      end

      buffer.join # wait here until the buffer is closed.

      self
    end
    
    def handle_command(buffer, command) # :nodoc:
      parts = command.split(' ')
      name = parts.shift
      value = parts.shift
      case name
        when "sleep"
          buffer.sleep_until value
        when "terminate"
          buffer.kill
        else
          buffer.write command
      end
    end
    
    def get_executable # :nodoc:
      exe = Sprout.get_executable(gem_name, gem_path, gem_version)
      User.clean_path(exe)
    end
    
    def command_queue # :nodoc:
      @queue
    end
    
    def kill_on_fault?
      @kill_on_fault
    end
    
    def test_result_file
      @test_result_file ||= TEST_RESULT_FILE
    end
    
    def test_result_prelude
      @test_result_prelude ||= TEST_RESULT_PRELUDE
    end
    
    def test_result_closing
      @test_result_closing ||= TEST_RESULT_CLOSING
    end
    
    # Print backtrace of all stack frames
    def bt
      @queue << "bt"
    end
    
    # Set breakpoint at specified line or function
    def break=(point)
      @queue << "break #{point}"
    end
    
    # Display the name and number of the current file
    def cf
      @queue << "cf"
    end
    
    # Clear breakpoint at specified line or function
    def clear=(point)
      @queue << "clear #{point}"
    end
    
    # Apply/remove conditional expression to a breakpoint
    def condition=(cond)
      @queue << "condition #{cond}"
    end
    
    # Continue execution after stopping at breakpoint
    def continue
      @queue << "continue"
    end

    # Alias for continue
    def c
      @queue << "continue"
    end
    
    # Sets commands to execute when breakpoint hit
    def commands=(cmd)
      @queue << "com #{cmd}"
    end
    
    # Delete breakpoints or auto-display expressions
    def delete
      @queue << "delete"
    end
    
    # Add a directory to the search path for source files
    def directory=(dir)
      @queue << "directory #{dir}"
    end
    
    # Disable breakpoints or auto-display expressions
    def disable
      @queue << "disable"
    end
    
    # Disassemble source lines or functions
    def disassemble
      @queue << "dissassemble"
    end
    
    # Add an auto-display expressions
    def display=(disp)
      @queue << "disp #{disp}"
    end
    
    # Enable breakpoints or auto-display expressions
    def enable
      @queue << "enable"
    end
    
    # Enable breakpoints or auto-display expressions
    def e
      @queue << "enable"
    end
    
    # Specify application to be debugged.
    def file=(file)
      @prerequisites << file
      @queue << "file #{file}"
      @file = file
    end
    
    # alias for self.file=
    def input=(file)
      self.file = file
    end
    
    # Execute until current function returns
    def finish
      @queue << "finish"
    end
    
    # Specify how to handle a fault
    def handle
      @queue << "handle"
    end
    
    # Set listing location to where execution is halted
    def home
      @queue << "home"
    end
    
    # Display information about the program being debugged
    def info
      @queue << "info"
    end

    # Argument variables of current stack frame
    def info_arguments
      @queue << "i a"
    end
    
    # Status of user-settable breakpoints
    def info_breakpoints
      @queue << "i b"
    end
    
    # Display list of auto-display expressions
    def info_display
      @queue << "i d"
    end
    
    # Names of targets and files being debugged
    def info_files
      @queue << "i f"
    end
    
    # All function names
    def info_functions=(value)
      @queue << "i fu #{value}"
    end
    
    # How to handle a fault
    def info_handle
      @queue << "i h"
    end
    
    # Local variables of current stack frame
    def info_locals
      @queue << "i l"
    end
    
    # Scope chain of current stack frame
    def info_scopechain
      @queue << "i sc"
    end
    
    # Source files in the program
    def info_sources
      @queue << "i so"
    end
    
    # Backtrace of the stack
    def info_stack
      @queue << "i s"
    end
    
    # List of swfs in this session
    def info_swfs
      @queue << "i sw"
    end
    
    # Application being debugged
    def info_targets
      @queue << "i t"
    end
    
    # All global and static variable names
    def info_variables
      @queue << "i v"
    end
    
    # Kill execution of program being debugged
    def kill
      @queue << "kill"
    end
    
    # List specified function or line
    def list
      @queue << "list"
    end
    
    # Step program
    def next
      @queue << "next"
    end
    
    # Print value of variable EXP
    def print=(msg)
      @queue << "print #{msg}"
    end

    # Print working directory
    def pwd
      @queue << "pwd"
    end
    
    # Exit fdb
    def quit
      @queue << "quit"
      @queue << "y"
      @queue << "terminate"
    end
    
    # Start debugged program
    def run
      @queue << "run"
    end
    
    # Set the value of a variable
    def set=(value)
      @queue << "set #{value}"
    end
    
    # Sleep until some 'str' String is sent to the output
    def sleep_until(str)
      @queue << "sleep #{str}"
    end
    
    # Read fdb commands from a file
    def source=(file)
      @queue << "source #{file}"
    end
    
    # Step program until it reaches a different source line
    def step
      @queue << "step"
    end
    
    # Force the Flash Debugger and running SWF to close
    def terminate
      @queue << "terminate"
    end
    
    # Remove an auto-display expression
    def undisplay
      @queue << "undisplay"
    end
    
    # Set or clear filter for file listing based on swf
    def viewswf
      @queue << "viewswf"
    end
    
    # Displays the context of a variable
    def what=(value)
      @queue << "what #{value}"
    end
    
    # Same as bt
    def where
      @queue << "bt"
    end
    
  end
  
  # A buffer that provides clean blocking support for the fdb command shell
  class FDBBuffer #:nodoc:
    attr_accessor :test_result_file
    attr_accessor :test_result_prelude
    attr_accessor :test_result_closing
    attr_writer :kill_on_fault

    PLAYER_TERMINATED = 'Player session terminated'
    EXIT_PROMPT = 'The program is running.  Exit anyway? (y or n)'
    PROMPT = '(fdb) '
    QUIT = 'quit'
    
    # The constructor expects a buffered input and output
    def initialize(exe, output, user_input=nil)
      @output = output
      @prompted = false
      @faulted = false
      @user_input = user_input
      @found_search = false
      @pending_expression = nil
      listen exe
    end
    
    def kill_on_fault?
      @kill_on_fault
    end
    
    def user_input
      @user_input ||= $stdin
    end
    
    def create_input(exe)
      ProcessRunner.new("#{exe}")
    end
    
    def sleep_until(str)
      @found_search = false
      @pending_expression = str
      while !@found_search do
        sleep(0.2)
      end
    end
    
    # Listen for messages from the input process
    def listen(exe)
      @input = nil
      @listener = Thread.new do
        @input = create_input(exe)
        def puts(msg)
          $stdout.puts msg
        end
        
        @inside_test_result = false
        full_output = ''
        test_result = ''
        char = ''
        line = ''
        while true do
          begin
            char = @input.readpartial 1
          rescue EOFError => e
            puts "End of File - Exiting Now"
            @prompted = true
            break
          end

          if(char == "\n")
            line = ''
          else
            line << char
            full_output << char
          end
          
          @output.print char
          @output.flush
          
          if(line == test_result_prelude)
            @inside_test_result = true
          end
          
          if(@inside_test_result)
            test_result << line
          end
          
          if(@inside_test_result && line == test_result_closing)
            write_test_result(test_result)
            kill
          end

          if(line == PROMPT || line.match(/\(y or n\) $/))
            full_output_cache = full_output
            line = ''
            full_output = ''
            @prompted = true
            if(should_kill?(full_output_cache))
              Thread.new {
                wait_for_prompt
                write('info stack') # Output the full stack trace
                write('info locals') # Output local variables
                write('kill') # Kill the running SWF file
                write('y') # Confirm killing SWF
                write('quit') # Quit FDB safely
              }
            end

          elsif(@pending_expression && line.match(/#{@pending_expression}/))
            @found_search = true
            @pending_expression = nil
          elsif(line == PLAYER_TERMINATED)
            puts ""
            puts "Closed SWF Connection - Exiting Now"
            @prompted = true
            break
          end
        end
      end
      
    end
    
    def should_kill?(message)
      return (@kill_on_fault && fault_found?(message))
    end
    
    def fault_found?(message)
      match = message.match(/\[Fault\]\s.*,.*$/) 
      return !match.nil?
    end
    
    def write_test_result(result)
      FileUtils.makedirs(File.dirname(test_result_file))
      File.open(test_result_file, File::CREAT|File::TRUNC|File::RDWR) do |f|
        f.puts(result)
      end
    end

    # Block for the life of the input process
    def join
      puts ">> Entering FDB interactive mode, type 'help' for more info."
      print PROMPT
      $stdout.flush

      Thread.new do
        while true do
          msg = user_input.gets.chomp!
          @input.puts msg
          wait_for_prompt
        end
      end

      @listener.join
    end
    
    # Block until prompted returns true
    def wait_for_prompt
      while !@prompted do
        sleep(0.2)
      end
    end
    
    # Kill the buffer
    def kill
      @listener.kill
    end
    
    # Send a message to the buffer input and reset the prompted flag to false
    def write(msg)
      @prompted = false
      @input.puts msg
      print msg + "\n"
      $stdout.flush
      if(msg != "c" && msg != "continue")
        wait_for_prompt
      end
    end
    
  end
end

def fdb(args, &block)
  Sprout::FDBTask.define_task(args, &block)
end

