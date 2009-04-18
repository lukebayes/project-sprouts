require File.dirname(__FILE__) + '/test_helper'

class LibraryTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    fixture                     = File.join(fixtures, 'library')
    
    @system_lib                 = File.join(fixture, 'cache')
    Sprout::Sprout.sprout_cache = @system_lib
    @system_asunit              = File.join(@system_lib, '/sprout-asunit3-library-3.2.8/', 'archive')
    
    @lib_dir                    = File.join(fixture, 'lib')
    @project_asunit             = File.join(@lib_dir, 'asunit3', 'asunit')

    @foo_dir                    = File.join(@lib_dir, 'foo', 'asunit')
    @core_swc                   = File.join(@lib_dir, 'corelib.swc')

    @input                      = File.join(fixture, 'SomeRunner.mxml')
    @output                     = File.join(fixture, 'SomeRunner.swf')
    @source_path                = File.join(fixture)

    model                       = Sprout::ProjectModel.instance
    model.lib_dir               = @lib_dir
    model.swc_dir               = @lib_dir
  end
  
  def teardown
    super
    Sprout::Sprout.sprout_cache = nil
    remove_file(@system_lib)
    remove_file(@lib_dir)

    remove_file(@core_swc)
    remove_file(@output)
  end
  
  def test_source_lib
    library :asunit3
    
    run_task :asunit3
    assert_file(@system_asunit)
    assert_file(@project_asunit)
  end
  
  def test_gem_name
    library :foo do |t|
      t.gem_name = 'sprout-asunit3-library'
    end
    
    run_task :foo
    assert_file(@foo_dir)
  end
  
  def test_swc_lib
    library :corelib
    
    run_task :corelib
    assert_file(@core_swc)
  end

end
