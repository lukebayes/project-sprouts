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
  
  def test_little_lexer
    input =<<EOF
Adobe Flex Compiler SHell (fcsh)
Version 3.0.0 build 477
Copyright (c) 2004-2007 Adobe Systems, Inc. All rights reserved.

(fcsh)
EOF

    lexer = Lexer.new([[/\n\(fcsh\)/, ?=], 
                       [/[\s\S]/, ?_],
                       ])
    string, list = lexer.scan(input) do |token, source|
      if(token == ?=)
        puts "HIT COMMAND PROMPT NOW!"
      end
    end
  end
  
end

