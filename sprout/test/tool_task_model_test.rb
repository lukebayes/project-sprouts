require File.dirname(__FILE__) + '/test_helper'
require 'fake_task_base'

class ToolTaskModelTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def teardown
    super
    clear_tasks
  end
  
  def test_project_model_properties
    tool_task_model :model do |t|
      t.unused_param = "SomeUnusedValue"
      t.debug = true
      t.source_path = []
      t.source_path << 'src'
      t.source_path << 'lib/asunit3'
      t.source_path << 'lib/corelib'
    end
    
    fake_task = fake_task_base :fake_task => :model do |t|
      t.input = 'SomeProject.as'
      t.source_path << 'test'
    end
    
    assert_equal('SomeProject.as -debug -source-path=src -source-path=lib/asunit3 -source-path=lib/corelib -source-path=test', fake_task.to_shell, "Task should have accepted values from prerequisite model")
  end
  
end
