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

module Sprout
  
  # TerminalAdapter is expected to read from a stream
  # as it changes, and throw events based on the messages
  # that the Terminal responds with.
  class TerminalAdapter

    def open(stream, tokens)
      @is_open = true
      Thread.new {
        index = 0
        processed = ''
        while(@is_open) do
          while(stream.size > index) do
            processed << stream[index].chr
            token = find_token(processed, tokens)
            yield token if !token.nil?
            index += 1
          end
          sleep(0.1)
        end
      }
    end
    
    def close
      @is_open = false
    end
    
    protected

    def find_token(str, tokens)
      tokens.each do |token|
        puts "checking #{str} #{token}"
        parts = str.match(token)
        if(!parts.nil?)
          return token
        end
      end
      return nil
    end

  end
end
