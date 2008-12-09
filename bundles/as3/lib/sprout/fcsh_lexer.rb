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
  # Unfortunately, LittleLexer did not support long-lived Stream input, which 
  # (I think) we needed.
  class FCSHLexer
    PROMPT  = ':prompt'
    WARNING = ':warning'
    ERROR   = ':error'
    PRELUDE = ':prelude'

    PRELUDE_EXPRESSION = /(Adobe Flex Compiler.*\n.*\nCopyright.*\n)/m

    def initialize(out=nil)
      @out = out || $stdout
      @regex_to_token = [
                        [/\n(.*Warning:.*\^.*)\n/m, WARNING], # Warning encountered
                        [/\n(.*Error:.*\^\s*)\n/m,  ERROR], # Error encountered
                        [PRELUDE_EXPRESSION,        PRELUDE],
                        [/\n\(fcsh\)/,              PROMPT] # Prompt for input
                       ]
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
        token, match = next_token(partial)
        if(token)
          tokens << {:token => token, :match => match}
          yield token, match if block_given?
          partial = ''
          puts "FOUND PROMPT" if token == PROMPT
          break if(token == PROMPT)
        end
      end
      return tokens
    end
    
    # Retrieve the next token from the string, and
    # return nil if no token is found
    def next_token(string)
      # puts "checking: #{string}"
      @regex_to_token.each do |regex, token|
        match = regex.match(string)
        if match
          puts "--------------------------"
          puts "token #{token}"
          return token, match
        end
      end
      return [nil, nil]
    end

    def join
      @t.join
    end

    def close
      @t.kill
    end

    private
    
    def out
      @out
    end
  end
end
