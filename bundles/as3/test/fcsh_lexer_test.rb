require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

class FCSHLexerTest <  Test::Unit::TestCase
  
  def run_lexer(input)
    fake_stdin, fake_stdout = IO.pipe
    reader, writer = IO.pipe
    lexer = Sprout::FCSHLexer.new(fake_stdout)

    t = Thread.new {
      sleep(0.2)
      index = 0
      while(index < input.size)
        writer.printf(input[index].chr)
        index += 1
        if((index % 10) == 0)
          writer.flush
          sleep(0.03)
        end
      end
    }
    
    tokens = []
    lexer.scan_stream(reader) do |token|
      tokens << token
    end
    return tokens
  end
  
  def test_warning
    tokens = run_lexer warning_text
    result = tokens.shift
    assert_equal(Sprout::FCSHLexer::WARNING, result[:name], 'Expected warning token')
    assert(result[:match][1].match(/\^/), 'Expected warning content')

    result = tokens.shift
    assert_equal(Sprout::FCSHLexer::PROMPT, result[:name])
  end

  def test_prelude
    tokens = run_lexer prelude_text
    result = tokens.shift
    assert_equal(Sprout::FCSHLexer::PRELUDE, result[:name], 'Expected prelude token')
    assert(result[:match][1].match(/Adobe Flex Compiler/), 'Expected prelude content')

    result = tokens.shift
    assert_equal(Sprout::FCSHLexer::PROMPT, result[:name])
  end

  def test_error
    tokens = run_lexer error_text
    result = tokens.shift
    assert_equal(Sprout::FCSHLexer::ERROR, result[:name], 'Expected error token')
    assert(result[:match][1].match(/\^/), 'Expected error content')
  end

  def prelude_text
    value =<<EOF
Adobe Flex Compiler SHell (fcsh)
Version 3.0.0 build 477
Copyright (c) 2004-2007 Adobe Systems, Inc. All rights reserved.

(fcsh)
EOF
  end
  
  def warning_text
    value =<<EOF

/Users/lbayes/Projects/Demo/SomeProject/src/SomeProject.as(10): col: 8 Warning: variable 'mine' has no type declaration.

                          var mine = [];
                              ^

(fcsh)
EOF
  end

  def error_text
    value =<<EOF

/Users/lbayes/Projects/Demo/SomeProject/src/SomeProject.as(10): col: 4 Error: Access of undefined property tr.

                          tr
                          ^

(fcsh)
EOF
  end

end
