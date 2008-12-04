require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

require 'little_lexer'

class TerminalAdapterTest <  Test::Unit::TestCase
  
  attr_reader :adapter
  
  def setup
    @adapter = Sprout::TerminalAdapter.new
    super
  end

  def teardown
    super
  end

  def test_fcsh_parser
    input =<<EOF
Adobe Flex Compiler SHell (fcsh)
Version 3.0.0 build 477
Copyright (c) 2004-2007 Adobe Systems, Inc. All rights reserved.

/Users/lbayes/Projects/Demo/SomeProject/src/SomeProject.as(10): col: 8 Warning: variable 'mine' has no type declaration.

                        var mine = [];
                            ^


/Users/lbayes/Projects/Demo/SomeProject/src/SomeProject.as(10): col: 4 Error: Access of undefined property tr.

                        tr
                        ^



(fcsh)

EOF

    reader, writer = IO.pipe

    lexer = FCSHLexer.new
    lexer.scan_stream(reader) do |token, match|
      case token
        when FCSHLexer::PRELUDE
          puts "[PRELUDE]"
        when FCSHLexer::WARNING
          puts "[WARNING] #{match[1]}"
        when FCSHLexer::ERROR
          puts "[ERROR] #{match[1]}"
        when FCSHLexer::PROMPT
          puts "[PROMPT]"
          lexer.close
        else
          puts "unexpected token found #{token} #{match}"
      end

    end
    
    index = 0
    while(index < input.size)
      writer.printf(input[index].chr)
      index += 1
      writer.flush
      sleep(0.02)
    end
    
    lexer.join
    
    puts "INDEX #{index} SIZE: #{input.size}"
    
  end

end

class FCSHLexer
  PROMPT  = ':prompt'
  WARNING = ':warning'
  ERROR   = ':error'
  PRELUDE = ':prelude'

  PRELUDE_EXPRESSION = /Adobe Flex Compiler.*\n.*\nCopyright.*\n/m

  def initialize
    @regex_to_char = [
                      [/\n\(fcsh\)/,               PROMPT], # Prompt for input
                      [/\n(.*Warning:.*\^\s+)\n/m, WARNING], # Warning encountered
                      [/\n(.*Error:.*\^\s+)\n/m,   ERROR], # Error encountered
                      [PRELUDE_EXPRESSION,         PRELUDE]
                     ]
  end
  
  def scan_stream(reader, out=nil)
    out = out || $stdout
    out.printf "Waiting for FCSH."
    
    @t = Thread.new {
      partial = ''
      index = 0
      while(!reader.eof?) do
        partial << reader.readpartial(1)
        token, match = next_token(partial)
        if(token)
          partial = ''
          out.puts ''
          yield token, match
        end
        
        if((index += 1) > 10)
          out.printf '.'
          out.flush
          index = 0
          sleep(0.02)
        end
      end
    }
    @t.abort_on_exception = true
  end

  def next_token(string)
    @regex_to_char.each do |regex, char|
      # puts "checking: #{string}"
      match = regex.match(string)
      if match
        return char, match # token, match
      end
    end
    return nil
  end

  def join
    @t.join
  end
  
  def close
    @t.kill
  end
  
end
