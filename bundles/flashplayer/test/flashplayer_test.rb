require File.dirname(__FILE__) + '/test_helper'

class FlashPlayerTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start                  = Dir.pwd
    fixture                 = File.join(fixtures, 'flashplayer')
    @swf                    = 'Runner.swf'
    @some_project           = 'SomeProject-debug.swf'
    @test_result            = 'Result.xml'
    @failure_result_file    = 'ResultFailure.xml'
    @error_result_file      = 'ResultError.xml'
    
    @generated_results      = 'AsUnitResults.xml'
    Dir.chdir fixture
  end
  
  def teardown
    remove_file @test_result
    remove_file @generated_results
    Dir.chdir @start
    clear_tasks
  end
  
  def test_compilation
    flashplayer :run => @swf do |t|
      t.test_result_file = @test_result
      t.do_not_focus = true
    end

    run_task(:run)
    assert_file(@test_result)
  end
  
  def test_asunit_failure
    failure_result = nil
    File.open(@failure_result_file, 'r') do |f|
      failure_result = f.read
    end

    assert_raise Sprout::AssertionFailure do 
      player_task = Sprout::FlashPlayerTask.new(:test_asunit_failure, Rake::application)
      player_task.examine_test_result(failure_result)
    end
    
  end

  def test_asunit_error
    error_result = nil
    File.open(@error_result_file, 'r') do |f|
      error_result = f.read
    end

    assert_raise Sprout::AssertionFailure do 
      player_task = Sprout::FlashPlayerTask.new(:test_asunit_error, Rake::application)
      player_task.examine_test_result(error_result)
    end
  end

  # def test_use_fdb
  #   flashplayer :run => @some_project do |t|
  #     t.use_fdb = true
  #   end
  #   
  #   run_task :run
  # end


end
