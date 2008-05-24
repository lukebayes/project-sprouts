require File.dirname(__FILE__) + '/test_helper'

class AsDocTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    super
    @start        = Dir.pwd
    @fixture      = File.join(fixtures, 'asdoc')
	  @input		    = 'src/SomeProject.as'
	  @output       = 'bin/SomeProject.swf'
	  @asunit       = 'lib/asunit'
	  @lib          = 'lib'
	  @src          = 'src'
	  @test         = 'test'
	  @doc          = 'doc'
	  @doc_index    = 'doc/index.html'
    Dir.chdir(@fixture)
  end
  
  def teardown
    super
    remove_file @output
    remove_file @doc
    Dir.chdir(@start)
  end

  def test_configure_directly
    asdoc :docs do |t|
      t.doc_sources << @asunit
      t.doc_sources << @src
      t.doc_sources << @test
    end
    
    run_task :docs
    
    assert_file @doc_index
  end

  def test_configure_as_dependency
    mxmlc @output do |t|
      t.input = @input
      t.source_path << @asunit
      t.source_path << @src
      t.source_path << @test
      t.library_path << @lib
    end
    
    asdoc :docs => @output
    
    run_task :docs
    
    assert_file @output
    assert_file @doc_index
  end
  
end
