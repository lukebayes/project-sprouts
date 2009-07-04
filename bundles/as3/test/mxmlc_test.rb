require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

class MXMLCTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start        = Dir.pwd
    fixture      = File.join(fixtures, 'mxmlc')

    @lib          = 'lib'
    @input        = 'src/SomeProject.as'
    @nested_input = 'src/display/OrangeBox.as'
    @output       = 'bin/SomeProject.swf'
    
    Dir.chdir(fixture)
  end
  
  def teardown
    remove_file(@output)
    Dir.chdir(@start)
    super
  end

  # Helper method for build declaration
  def build_application
    task :application => @output
    
    mxmlc @output do |t|
      t.input       = @input
      t.source_path << @lib
    end
  end
  
  def build_model
    # Configure the ProjectModel for compilation
    model = Sprout::ProjectModel.setup do |m|
      m.source_path << 'foo'
      m.library_path << 'bar'
      m.project_name = 'SomeProject'
      m.width = 800
      m.height = 550
    end
  end
  
  # Did the input get added as a rake prerequisite?
  def test_simplest_compiler_setup
    compiler = mxmlc @output do |t|
      t.input       = @input
    end

    reqs = compiler.prerequisites
    assert_equal(7, reqs.size, "There should be 5 requirements set up by the task")
  end
  
  def test_nested_input
    compiler = mxmlc @output do |t|
      t.input       = @nested_input
      t.source_path << 'src'
    end
    
#    compiler.source_path.each do |path|
#      puts ">> #{path}"
#    end
    
    assert_equal(1, compiler.source_path.size)
    assert_equal('src', compiler.source_path[0])

    reqs = compiler.prerequisites
    assert_equal(7, reqs.size, "There should be 5 requirements set up by the task")
  end
  
  def test_fonts_languages_with_shell_name
    some_task = Sprout::MXMLCTask.new(:some_task, Rake::application)
    some_task.fonts_languages_language_range = 'hello'
    assert_equal('-compiler.fonts.languages.language-range=hello', some_task.to_shell)
  end
  
  def test_use_network_false
    some_task = Sprout::MXMLCTask.new(:some_task, Rake::application)
    some_task.use_network = false
    assert_equal('-use-network=false', some_task.to_shell)
    some_task.use_network = true
    assert_equal('', some_task.to_shell)
  end
  
  def test_css_input
    some_task = Sprout::MXMLCTask.new(:some_task, Rake::application)
    some_task.input = "src/SomeFile.css"
    some_task.define
    assert_equal('src/SomeFile.css', some_task.to_shell)
  
    
    some_task.output = 'bin/SomeFile.swf'
    assert_equal('-output=bin/SomeFile.swf src/SomeFile.css', some_task.to_shell)
  end
  
  def test_unique_source_path
    some_task = Sprout::MXMLCTask.new(:some_task, Rake::application)
    some_task.source_path << 'foo'
    some_task.source_path << 'foo'
    some_task.source_path << 'bar'
    some_task.input = 'foo/SomeFile.as'
    some_task.define

    assert_equal(2, some_task.source_path.size)
  end
  
  def test_includes_path
    some_task = Sprout::MXMLCTask.new(:some_task, Rake::application)
    some_task.source_path << 'src'
    some_task.include_path << 'src'
    some_task.input = 'src/SomeProject.as'
    some_task.define
    
    assert_equal('-includes+=display.OrangeBox -includes+=SomeFile -includes+=SomeProject -includes+=SomeProjectFailure -includes+=SomeProjectRunner -includes+=SomeProjectWarning -source-path+=src src/SomeProject.as', some_task.to_shell)
  end
    
end
