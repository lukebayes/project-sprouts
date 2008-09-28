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
    t = direct_configuration
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
    
    assert_equal("-output=doc -source-path+=src -templates-path+=#{ENV['HOME']}/Library/Sprouts/cache/0.7/sprout-flex3sdk-tool-3.0.2/archive/asdoc/templates", t.to_shell)
  end
  
  def test_automatic_template_path
    t = asdoc :docs

    assert(t.to_shell.match(/-templates-path\+=.*\/Sprouts\/cache\//))
  end

	def test_exclude_expressions
		t = direct_configuration
		t.exclude_expressions << 'lib/asunit/**/*'
		t.exclude_expressions << 'test/**/*'

		excluded_classes = %w{ asunit.asunit.util.Properties asunit.asunit.util.Iterator asunit.asunit.util.ArrayIterator asunit.asunit.textui.XMLResultPrinter asunit.asunit.textui.TestRunner asunit.asunit.textui.ResultPrinter asunit.asunit.textui.FlexTestRunner asunit.asunit.textui.FlexRunner asunit.asunit.runner.Version asunit.asunit.runner.TestSuiteLoader asunit.asunit.runner.BaseTestRunner asunit.asunit.framework.TestSuite asunit.asunit.framework.TestResult asunit.asunit.framework.TestMethod asunit.asunit.framework.TestListener asunit.asunit.framework.TestFailure asunit.asunit.framework.TestCaseExample asunit.asunit.framework.TestCase asunit.asunit.framework.Test asunit.asunit.framework.RemotingTestCase asunit.asunit.framework.AsynchronousTestCaseExample asunit.asunit.framework.AsynchronousTestCase asunit.asunit.framework.Assert asunit.asunit.errors.UnimplementedFeatureError asunit.asunit.errors.InstanceNotFoundError asunit.asunit.errors.ClassNotFoundError asunit.asunit.errors.AssertionFailedError asunit.asunit.errors.AbstractMemberCalledError utils.MathUtilTest AllTests }.join( " -exclude-classes=" )
    assert_equal("-doc-sources+=lib/asunit -doc-sources+=src -doc-sources+=test -library-path+=lib -output=doc -templates-path+=foo -exclude-classes=#{excluded_classes}", t.to_shell)
	end

	private

	def direct_configuration
		asdoc :docs do |t|
      t.doc_sources << @asunit
      t.doc_sources << @src
      t.doc_sources << @test
      # Need to force templates_path so that these tests run on different machines
      t.templates_path << 'foo'
    end
	end

end
