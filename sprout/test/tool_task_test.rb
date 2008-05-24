require File.dirname(__FILE__) + '/test_helper'
require 'fake_task_base'

class ToolTaskTest <  Test::Unit::TestCase
  include SproutTestCase

  def setup
    super
    @fixture = File.dirname(__FILE__) + '/fixtures/tool_task'
    @start = Dir.pwd
    @tool = Sprout::MockTool.new :tool_test
    @task = FakeTaskBase.new(:fake_task, Rake::application)
    Dir.chdir(@fixture)
  end
  
  def teardown
    super
    remove_file('fake_task')
    clear_tasks
    Dir.chdir(@start)
  end

  def test_params
    assert_equal(3, @tool.params.size)
  end
  
  def test_to_shell
    result = @tool.to_shell
    assert_equal("-debug=true", result)
  end
  
  def test_to_rdoc
    result = @tool.to_rdoc
    # Just check a subset of the generated docs
    assert(result.index("source_path=(paths)"))
  end

  def test_boolean_accessor
    @task.debug = true
    assert_equal('-debug', @task.to_shell)
  end

  def test_unknown_accessor
    assert_raises(NoMethodError) do
      @task.unknown = true
    end
  end
  
  def test_array_accessor
    @task.source_path << 'src'
    result = @task.to_shell
    assert_equal('-source-path=src', result)
  end
  
  def test_multiple_array_accessor
    @task.source_path << 'src'
    @task.source_path << 'lib'
    @task.source_path << 'test'
    result = @task.to_shell
    assert_equal('-source-path=src -source-path=lib -source-path=test', result)
  end
  
  def test_multiple_array_default_delimiter
    @task.library_path << 'src'
    @task.library_path << 'lib'
    @task.library_path << 'test'
    result = @task.to_shell
    assert_equal('-library-path+=src -library-path+=lib -library-path+=test', result)
  end
  
  def test_hidden_name
    @task.hidden_name_param = 'SomeProject.as'
    result = @task.to_shell
    assert_equal('SomeProject.as', result)
  end
  
  def test_param_alias
    @task.sp << 'src'
    @task.sp << 'lib'
    @task.sp << 'test'
    result = @task.to_shell
    assert_equal('-source-path=src -source-path=lib -source-path=test', result)
  end
  
  def test_number_param_and_prefix
    @task.frame_rate = 24
    result = @task.to_shell
    assert_equal('--frame-rate=24', result)
  end

  def test_show_on_false
    @task.as3 = false
    result = @task.to_shell
    assert_equal('-as3=false', result)
  end
  
  def test_string_param_with_spaces
    @task.default_size = '500 600'
    result = @task.to_shell
    assert_equal("-default-size 500 600", result)
  end

  def test_files_param_prerequisites

    fake_task_base :fake_task do |t|
      t.input = 'SomeProject.as'
      t.source_path << 'test/SourceClass.as'
      t.library_path << 'src'
      t.library_path << 'src' #Ensure duplicate entires don't persist
    end

    reqs = Rake::application[:fake_task].prerequisites
    run_task :fake_task
    
    assert_file('fake_task')
    assert_equal(5, reqs.size, "Prerequisites were not created properly")
    
    input = reqs.shift
    assert_equal('SomeProject.as', input.to_s)

    input = reqs.shift
    assert_equal('test/SourceClass.as', input.to_s)

    input = reqs.shift
    assert_equal('src/FooClass.as', input.to_s)
    
    input = reqs.shift
    assert_equal('src/OtherClass.as', input.to_s)
    
    input = reqs.shift
    assert_equal('src/SomeClass.as', input.to_s)
    
  end
  
  def test_path_param_cleaned
    
    @task.library_path << '~/Library/Foo Project'    
    @task.prepare
    result = @task.library_path[0];
    assert_equal('~/Library/Foo\ Project', result)
  end
  
  def test_prepend_args
    @tool.debug = true
    @tool.prepended_args = '--increment-revision'
    assert_equal('--increment-revision -debug=true', @tool.to_shell)
  end

  def test_append_args
    @tool.debug = true
    @tool.appended_args = '--increment-revision'
    assert_equal('-debug=true --increment-revision', @tool.to_shell)
  end

end

module Sprout
  class MockTool < ToolTask
    
    def initialize(name)
      super(name, Rake::application)
    end
    
    def initialize_task
      super
      add_param(:debug, :boolean) do |t|
        t.value = true
        t.description = "Toggle debug value"
      end
      
      add_param(:source_path, :paths) do |t|
        t.description = "Add zero or more directories to the source path lookup"
      end
      
      add_param(:input, :file)
    end
  end
end