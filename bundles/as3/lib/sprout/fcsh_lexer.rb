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
=end

module Sprout
  
  # This class should allow us to parse the stream output that FCSH provides.
  # It was largely inspired by "LittleLexer" (http://rubyforge.org/projects/littlelexer/)
  # which is a beautiful and concise general purpose lexer written by John Carter.
  # Unfortunately, LittleLexer did not support streamed input, which 
  # we definitely need.
  class FCSHLexer
    PROMPT  = ':prompt'
    WARNING = ':warning'
    ERROR   = ':error'
    PRELUDE = ':prelude'

    PRELUDE_EXPRESSION = /(Adobe Flex Compiler.*\n.*\nCopyright.*\n)/m

    def initialize(out=nil)
      @out = out || $stdout
      @regex_to_token = [
                        [/(.*Warning:.*\^.*)\n/m,   WARNING], # Warning encountered
                        [/(.*Error:.*\^.*)\n/m,     ERROR], # Error encountered
                        [PRELUDE_EXPRESSION,        PRELUDE],
                        [/\n\(fcsh\)/,              PROMPT] # Prompt for input
                       ]
    end
    
    def scan_process(process_runner)
      tokens = [];
      # Collect Errors and Warnings in a way that doesn't
      # Block forever when we have none....
      t = Thread.new {
        scan_stream(process_runner.e) do |token|
          yield token if block_given?
          tokens << token
        end
      }
      
      # Collect stdout from the process:
      scan_stream(process_runner.r) do |token|
        yield token if block_given?
        tokens << token
      end
      
      process_runner.e.sync = true

      # GROSS HACK! 
      # It seems we need to wait
      # for the fsch $stderr buffer to flush?
      # There must be a better way... Anyone?
      # Should we move to Highline for interactive
      # shell applications?
      # http://rubyforge.org/projects/highline/
      # In fact - this problem actually ruins
      # the entire implementation, the larger/longer
      # it takes for errors to be bufferred, the more
      # likely it is we'll return without displaying them.
      # The only way to overcome this with the current 
      # implementation, is to increase the timeout so that
      # FCSH takes a long, long time on every compilation!!!
      sleep(0.2)
      
      t.kill
      return tokens
    end

    # We need to scan the stream as FCSH writes to it. Since FCSH is a
    # persistent CLI application, it never sends an EOF or even a consistent
    # EOL. In order to tokenize the output, we need to attempt to check 
    # tokens with each character added.
    # scan_stream will block and read characters from the reader provided until
    # it encounters a PROMPT token, at that time, it will return an array
    # of all tokens found.
    # It will additionally yield each token as it's found if a block is provided.
    def scan_stream(reader)
      tokens = []
      partial = ''
      index = 0
      while(true) do
        code = reader.getc
        return if code.nil?
        
        partial << code.chr
        token = next_token(partial)
        if(token)
          tokens << token
          yield token if block_given?
          partial = ''
          break if(token[:name] == PROMPT || token[:name] == ERROR)
        end
      end
      
      return tokens
    end
    
    private

    # Retrieve the next token from the string, and
    # return nil if no token is found
    def next_token(string)
      # puts "checking: #{string}"
      @regex_to_token.each do |regex, token_name|
        match = regex.match(string)
        if match
          return {:name => token_name, :match => match, :output => get_output(token_name, match)}
        end
      end
      return nil
    end
    
    def get_output(name, match)
      if(name == PROMPT)
        return match.pre_match + "\n"
      else
        return match[0] + "\n"
      end
    end

    def out
      @out
    end
  end
end
