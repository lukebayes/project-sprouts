require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

class TerminalAdapterTest <  Test::Unit::TestCase
  
  def input
      value =<<EOF
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
  end
  
  def test_fcsh_parser
    found = []
    fake_stdin, fake_stdout = IO.pipe
    
    reader, writer = IO.pipe

    lexer = Sprout::FCSHLexer.new
    lexer.scan_stream(reader, fake_stdout) do |token, match|
      case token
        when Sprout::FCSHLexer::PRELUDE
          found << {:token => token, :match => match}
        when Sprout::FCSHLexer::WARNING
          found << {:token => token, :match => match}
          # puts "[WARNING] #{match[1]}"
        when Sprout::FCSHLexer::ERROR
          found << {:token => token, :match => match}
          # puts "[ERROR] #{match[1]}"
        when Sprout::FCSHLexer::PROMPT
          found << {:token => token, :match => match}
          # puts "[PROMPT]"
          lexer.close
        else
          puts "unexpected token found #{token} #{match}"
      end
    end
    
    index = 0
    while(index < input.size)
      writer.printf(input[index].chr)
      index += 1
      if((index % 10) == 0)
        writer.flush
        sleep(0.02)
      end
    end
    
    result = found.shift
    assert_equal(Sprout::FCSHLexer::PRELUDE, result[:token])
    assert(result[:match][1].match(/Adobe Flex Compiler/))
    result = found.shift
    assert_equal(Sprout::FCSHLexer::WARNING, result[:token])
    assert(result[:match][1].match(/\^/))
    result = found.shift
    assert_equal(Sprout::FCSHLexer::ERROR, result[:token])
    assert(result[:match][1].match(/\^/))
    result = found.shift
    assert_equal(Sprout::FCSHLexer::PROMPT, result[:token])
  end

end

