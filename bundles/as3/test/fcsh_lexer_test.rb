require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

require 'sprout/fcsh_lexer'

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

    lexer = Sprout::FCSHLexer.new
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

