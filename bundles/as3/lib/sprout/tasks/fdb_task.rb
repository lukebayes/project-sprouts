
module Sprout #:nodoc:
  
  class FDBTaskError < StandardError #:nodoc:
  end

  class FDBTask < ToolTask
    # The SWF file to debug.
    attr_accessor :swf

    def initialize_task
      @default_gem_name = 'sprout-flex3sdk-tool'
      @default_gem_path = 'bin/fdb'
      @queue = []
    end

    def define
      self
    end
    
    def stdout=(out)
      @stdout = out
    end
    
    def stdout
      @stdout ||= $stdout
    end
    
    def execute(*args)
      debugger = create_process
      buffer = FDBBuffer.new(debugger, stdout)
      
      @queue.each do |command|
        buffer.wait_for_prompt
        buffer.puts command
      end
      
      buffer.join

      self
    end
    
    def enter_interactive_mode(debugger)
      puts ">> Entering Interactive Debugger Mode, type 'help' for more info"
      execute_command(debugger, $stdin.gets)
      enter_interactive_mode(debugger)
    end
    
    def create_process
      exe = Sprout.get_executable(gem_name, gem_path, gem_version)
      tool = User.clean_path(exe)
      return ProcessRunner.new("#{tool}")
    end
    
    def command_queue
      @queue
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
      @queue << "file #{file}"
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
    def info_functions
      @queue << "i fu"
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
    end
    
    # Start debugged program
    def run
      @queue << "run"
    end
    
    # Set the value of a variable
    def set=(value)
      @queue << "set #{value}"
    end
    
    # Read fdb commands from a file
    def source=(file)
      @queue << "source #{file}"
    end
    
    # Step program until it reaches a different source line
    def step
      @queue << "step"
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
  class FDBBuffer
    PROMPT = '(fdb) '
    QUIT = 'quit'
    
    # The constructor expects a buffered input and output
    def initialize(input, output, user_input=nil)
      @input = input
      @output = output
      @user_input = user_input
      listen
    end
    
    def user_input
      @user_input ||= $stdin
    end
    
    # Listen for messages from the input process
    def listen
      @prompted = false
      @listener = Thread.new do

        def puts(msg)
          $stdout.puts msg
        end
        
        char = ''
        line = ''
        while true do
          if(char == "\n")
            line = ''
          end
          char = @input.readpartial 1
          @output.print char
          line << char
          if(line == PROMPT)
            @prompted = true
            @output.flush
          end
        end
      end
    end

    # Block for the life of the input process
    def join
      $stdout.puts ">> Entering FDB interactive mode, type 'help' for more info."
      $stdout.print "(fdb) "
      $stdout.flush
      looping = true
      while looping do
        msg = user_input.gets
        if(msg.chomp! == QUIT)
          looping = false
        else
          @input.puts msg
          wait_for_prompt
        end
      end
    end
    
    # Block until prompted? returns true
    def wait_for_prompt
      sleep(0.2)
      while(!prompted?)
        sleep(0.2)
      end
    end
    
    # Kill the buffer
    def kill
      @listener.kill
    end
    
    # Send a message to the buffer input and reset the prompted? flag to false
    def puts(msg)
      @prompted = false
      @input.puts msg
    end
    
    # Has a prompt been encountered since the last call to puts?
    def prompted?
      return @prompted
    end
    
  end
end

def fdb(args, &block)
  Sprout::FDBTask.define_task(args, &block)
end

