
module Sprout
  
  # A buffer that provides clean blocking support for the fdb command shell
  class FDBBuffer #:nodoc:
    attr_accessor :test_result_file
    attr_accessor :test_result_prelude
    attr_accessor :test_result_closing

    attr_reader :runtime_exception_encountered
    attr_writer :kill_on_fault

    PLAYER_TERMINATED = 'Player session terminated'
    EXIT_PROMPT = 'The program is running.  Exit anyway? (y or n)'
    PROMPT = '(fdb) '
    QUIT = 'quit'
    
    # The constructor expects a buffered input and output
    def initialize runner, output, user_input=nil
      @output = output
      @prompted = false
      @faulted = false
      @user_input = user_input
      @found_search = false
      @pending_expression = nil
      listen runner
    end
    
    def kill_on_fault?
      @kill_on_fault
    end
    
    def user_input
      @user_input ||= $stdin
    end
    
    def sleep_until(str)
      @found_search = false
      @pending_expression = str
      while !@found_search do
        sleep(0.2)
      end
    end
    
    # Listen for messages from the input process
    def listen runner
      @input = nil
      @listener = Thread.new do
        @input = runner
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
            if(@inside_test_result && !line.index(test_result_prelude))
              test_result << line + char
            end
            line = ''
          else
            line << char
            full_output << char
          end

          if(!@inside_test_result)
            @output.print char
            @output.flush
          end
          
          if(!test_result_prelude.nil? && line.index(test_result_prelude))
            test_result = ''
            @inside_test_result = true
          end
          
          if(@inside_test_result && line.index(test_result_closing))
            write_test_result(test_result)
            @inside_test_result = false
            Thread.new {
              write("\n")
              write('y')
              write('kill')
              write('y')
              write('quit')
            }
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
                @runtime_exception_encountered = true
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
    
    def clean_test_result(result)
      return result.gsub(/^\[trace\]\s/m, '')
    end
    
    def write_test_result(result)
      result = clean_test_result result
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

      t = Thread.new {
        while true do
          input = user_input.gets
          break if input.nil?
          msg = input.chomp!
          @input.puts msg
          wait_for_prompt
        end
      }

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

