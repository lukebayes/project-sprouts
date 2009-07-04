require File.dirname(__FILE__) + '/test_helper'

class ADLTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start        = Dir.pwd
    fixture      = File.join(fixtures, 'air')
    
    @root_directory = fixture
    @application_descriptor = "src/SomeProject-app.xml"

    Dir.chdir(fixture)
  end
  
  def teardown
    Dir.chdir(@start)
    super
  end

  # Helper method for build declaration
  def build_application
    task :application => test_adl
    
    adl :test_adl do |t|
      t.root_directory = @root_directory
      t.application_descriptor = @application_descriptor
    end
  end
  
  # Test launcher task
  def test_launcher
    runtime = ENV['FLEX_HOME'] + "/runtimes/air/mac/Adobe AIR.framework/Adobe AIR"
    
    launcher = adl :test_adl do |t|
      t.runtime = runtime
      t.nodebug = true
      t.pubid = "THEPUBID"
      t.root_directory = @root_directory
      t.application_descriptor = @application_descriptor
      t.arguments = "arg1 arg2"
    end
    
    command = "-runtime #{runtime} -nodebug -pubid THEPUBID src/SomeProject-app.xml #{@root_directory} -- arg1 arg2"
    assert_equal command, launcher.to_shell      
  end
  
end
