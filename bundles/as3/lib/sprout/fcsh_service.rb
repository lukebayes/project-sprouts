=begin
Copyright (c) 2007 Pattern Park

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

TODO: Investigate jruby support, especially:
    http://livedocs.adobe.com/flex/201/html/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Book_Parts&file=compilers_123_09.html
=end

require 'sprout/fcsh_lexer'
require 'digest/md5'

module Sprout
  class FCSHError < StandardError #:nodoc:
  end

  class FCSHService
    # This is probably a dumb, overused port number.
    # Isn't it the default for Tomcat or something?
    # Any safer / more compatible suggestions are welcome!
    # DEFAULT_PORT = 8090
    
    def initialize(out=nil)
      @out = out || $stdout
      @tasks = []
      @lexer = FCSHLexer.new @out

      # TODO: This should use configurable SDK destinations:
      exe = Sprout.get_executable('sprout-flex3sdk-tool', 'bin/fcsh')
      @process = User.execute_silent(exe)
      @lexer.scan_stream(@process) # Block until the next prompt...
    end
    
    def execute(request)
      hashed = Digest::MD5.hexdigest(request)
      @out.puts "(fcsh) #{request}"
      
      # First, see if we've already received a task with this
      # Exact command:
      @tasks.each_index do |index|
        task = @tasks[index]
        if(task[:hash] == hashed)
          # Compile with an existing task at index+1
          write "compile #{index+1}"
          return
        end
      end

      task = {:hash => hashed, :request => request, :executed => false}
      @tasks << task
      write task[:request]
    end
    
    def close
      puts "======================"
      @process.close
    end
    
    private
    
    def write(message)
      @process.puts "#{message}\n"
      @lexer.scan_stream(@process).each do |token|
        @out.puts token[:match].pre_match
      end
    end

=begin
      # No existing task found, create a new one and add to pending:
      task = {:hash => hashed, :request => request, :shortcut => "compile #{@tasks.size}", :executed => false}
      @tasks << task
      @pending << task
      
      execute_next
    end
    
    def execute_next
      if(!@busy && @pending.size > 0)
        task = @pending.shift
        @out.print "#{task[:request]}\n"
        if(task[:executed])
          write task[:shortcut]
        else
          write task[:request]
          task[:executed] = true
        end
      end
    end
=end
    
  end
end
