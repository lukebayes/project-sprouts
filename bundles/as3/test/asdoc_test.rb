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
    t = asdoc :docs do |t|
      t.doc_sources << @asunit
      t.doc_sources << @src
      t.doc_sources << @test
      # Need to force templates_path so that these tests run on different machines
      t.templates_path << 'foo'
    end
    
    assert_equal('-doc-sources+=lib/asunit -doc-sources+=src -doc-sources+=test -output=doc -templates-path+=foo', t.to_shell)
  end

  def test_configure_as_dependency
    mxmlc @output do |t|
      t.input = @input
      t.source_path << @asunit
      t.source_path << @src
      t.source_path << @test
      t.library_path << @lib
    end
    
    t = asdoc :docs => @output do |t|
      # Need to force templates_path so that these tests run on different machines
      t.templates_path << 'foo' 
    end
    
    assert_equal('-doc-sources+=lib/asunit -doc-sources+=src -doc-sources+=test -library-path+=lib -output=doc -templates-path+=foo', t.to_shell)
  end
  
  def test_configure_with_source_paths
    t = asdoc :docs do |t|
      t.source_path << 'src'
    end
    
    assert_equal('-output=doc -source-path+=src -templates-path+=/Users/lbayes/Library/Sprouts/cache/0.7/sprout-flex3sdk-tool-3.0.2/archive/asdoc/templates"', t.to_shell)
  end
  
  def test_automatic_template_path
    t = asdoc :docs

    assert(t.to_shell.match(/-templates-path\+=.*\/Sprouts\/cache\//))
  end

end
