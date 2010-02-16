require File.dirname(__FILE__) + '/test_helper'

class ERBResolverTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    super
    @fixture = File.join(fixtures, 'erb_resolver')
    @html_output = File.join(@fixture, 'template.html')
    @reserved_output = File.join(@fixture, 'reserved.txt')
  end
  
  def teardown
    super
    remove_file @custom_output
    remove_file @html_output
    remove_file @reserved_output
  end
  
  def test_automatically_finds_template
    erb_task = erb_resolver @html_output do |t|
      t.world_name = 'World'
    end
    erb_task.invoke
    
    assert_file @html_output
    assert_matches 'Hello World!', File.open(@html_output).read
  end
  
  def test_template_uses_reserved_word
    erb_task = erb_resolver @reserved_output do |t|
      t.name = 'World'
    end
    erb_task.invoke
    assert_file @reserved_output
    assert_matches 'Hello World!', File.open(@reserved_output).read
  end
  
end