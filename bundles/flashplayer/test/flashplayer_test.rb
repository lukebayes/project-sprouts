require File.dirname(__FILE__) + '/test_helper'

class FlashPlayerTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start                  = Dir.pwd
    fixture                 = File.join(fixtures, 'flashplayer')
    @swf                    = 'Runner.swf'
    @some_project_debug     = 'SomeProject-debug.swf'
    @some_project           = 'SomeProject.swf'
    @test_result            = 'Result.xml'
    @failure_result_file    = 'ResultFailure.xml'
    @error_result_file      = 'ResultError.xml'
    @exception_swf          = 'InstantRuntimeException.swf'
    @mm_cfg                 = File.join(fixture, 'mm.cfg')
    @blank_mm_cfg           = File.join(fixture, 'blank-mm.cfg')
    
    @generated_results      = 'AsUnitResults.xml'
    Dir.chdir fixture
  end
  
  def teardown
    remove_file @test_result
    remove_file @generated_results
    remove_file @mm_cfg
    remove_file @blank_mm_cfg
    Dir.chdir @start
    clear_tasks
  end
  
  def test_asunit_result_file
    flashplayer :run => @swf do |t|
      t.test_result_file = @test_result
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
  
  def test_instant_runtime_exception
    flashplayer :run_broken => @exception_swf
    t = Thread.new {
      run_task(:run_broken)
    }
    player = get_task(:run_broken)
    sleep(4.0)
    player.close
  end
  
  def test_launch_swf
    flashplayer :run_project do |t|
      t.swf = @some_project
    end
    t = Thread.new {
      run_task(:run_project)
    }
    player = get_task(:run_project)
    sleep(4.0)
    player.close
    t.kill
  end

  def test_mm_config_missing
    config = Sprout::FlashPlayerConfig.new
    config.stubs(:config_path).returns(@mm_cfg)
    config.stubs(:user_confirmation?).returns true
    path = config.create_config_file
    assert_file path
    content = File.read path
    assert_matches /TraceOutputFileName=#{path}/, content
  end


  def test_mm_config_blank
    File.open(@blank_mm_cfg, 'w+') do |f|
      f.write ''
    end
    assert_file @blank_mm_cfg

    config = Sprout::FlashPlayerConfig.new
    config.stubs(:config_path).returns @blank_mm_cfg
    config.expects(:user_confirmation?).returns true
    path = config.create_config_file
    assert_file path
    content = File.read path
    assert_matches /TraceOutputFileName=#{path}/, content
  end
  
  # def test_use_fdb
  #   flashplayer :run => @some_project_debug do |t|
  #     t.use_fdb = true
  #   end
  #   
  #   run_task :run
  # end


end
