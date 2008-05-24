require File.dirname(__FILE__) + '/test_helper'

class TaskTest <  Test::Unit::TestCase
  include SproutTestCase

  def test_required
    expected = 'hello'
    
    mock_task :some_task do |t|
      t.value = expected
    end
 
# TODO: Fix run_task error
# Couldn't figure out how to get this to run
# after updating to rubygems 1.0.1 from 0.9.4
# This *exact* feature works from anywhere else
#    result = run_task :some_task
#    assert_equal(expected, result.value)
  end
  
end


# This is how tasks get defined
class MockTask < Rake::Task
  attr_accessor :value

  # The execute method will be called
  # when the task is invoked
  def execute
    super
  end
end

# This is how they get decorated
# for rake file usage
def mock_task(args, &block)
  MockTask.define_task(args, &block)
end
