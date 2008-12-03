require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

class TerminalAdapterTest <  Test::Unit::TestCase
  attr_reader :adapter
  
  def setup
    @adapter = Sprout::TerminalAdapter.new
    super
  end

  def teardown
    super
  end
  
  def test_find_simple_token
    tokens = ['a']
    stream = 'bcd'
    found = []
    adapter.open(stream, tokens) do |token|
      found << token
    end

    stream << 'e'
    stream << 'f'
    stream << 'a'
    sleep(0.2)
    
    assert_equal 1, found.size
    assert_equal 'a', found[0]
    adapter.close
  end
  
  def test_find_deeper_token
    tokens = ["\n(fcsh)"]
    out =<<EOF
Adobe Flex Compiler SHell (fcsh)
Version 3.0.0 build 477
Copyright (c) 2004-2007 Adobe Systems, Inc. All rights reserved.

(fcsh)
EOF

    found = []
    adapter.open(out, tokens) do |token|
      puts "FOUND #{token}"
      found << token
    end
    assert_equal 1, found.size
    adapter.close
  end
  
end

