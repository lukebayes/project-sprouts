require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../../../sprout/lib/sprout/project_model'

class MXMLCHelperTest <  Test::Unit::TestCase
  include SproutTestCase

  def setup
    @start        = Dir.pwd
    fixture       = File.join(fixtures, 'mxmlc')

    @lib          = 'lib'
    @input        = 'src/SomeProject.as'
    @output       = 'bin/SomeProject.swf'
    
    Dir.chdir(fixture)
  end
  
  def teardown
    remove_file(@output)
    Dir.chdir(@start)
    super
  end
  
  def create_model
    # Configure the ProjectModel for compilation
    model = Sprout::ProjectModel.setup do |m|
      m.source_path << 'foo'
      m.source_path << 'assets'
      m.library_path << 'bar'
      m.project_name = 'SomeProject'
      m.background_color = '#FFFFFF'
      m.width = 800
      m.height = 550
    end
  end

  def test_get_task_name_symbol
    helper = Sprout::MXMLCHelper.new(:demo_symbol)
    assert_equal('demo_symbol', helper.task_name)
  end
  
  def test_get_task_name_hash
    task :foo
    task :bar
    
    helper = Sprout::MXMLCHelper.new :demo_hash => [:foo, :bar] 
    assert_equal('demo_hash', helper.task_name)
  end

  def test_debug_helper
    create_model
    
    # And now configure the specific compiler instance
    # individually
    debug :debug do |t|
      t.default_size = '900 600'
    end
    
    # Get the MXMLC build task out:
    t = Rake::application['bin/SomeProject-debug.swf']
    assert_equal('-debug -default-background-color=#FFFFFF -default-frame-rate=24 -default-size 900 600 -library-path+=bar -output=bin/SomeProject-debug.swf -source-path+=src -source-path+=foo -source-path+=assets -verbose-stacktraces=true -warnings=true src/SomeProject.as', t.to_shell)
  end
  
  def test_test_helper
    create_model
    
    unit :test
    
    t = Rake::application['bin/SomeProjectRunner.swf']
    t.define

    # The test method will modify the width unless otherwise specified within the task itself
    assert_equal('-debug -default-background-color=#FFFFFF -default-frame-rate=24 -default-size 550 900 -library-path+=bar -output=bin/SomeProjectRunner.swf -source-path+=src -source-path+=foo -source-path+=assets -source-path+=test -source-path+=lib/asunit3 -verbose-stacktraces=true -warnings=true src/SomeProjectRunner.as', t.to_shell)
  end
  
  def test_deploy_helper
    create_model
    
    deploy :deploy
    
    t = Rake::application['bin/SomeProject.swf']
    t.define

    assert_equal('-default-background-color=#FFFFFF -default-frame-rate=24 -default-size 800 550 -library-path+=bar -optimize=true -output=bin/SomeProject.swf -source-path+=src -source-path+=foo -source-path+=assets src/SomeProject.as', t.to_shell)
  end
  
  def test_stylesheet_helper
    create_model
    
    stylesheet :style
    
    t = Rake::application['bin/SomeProjectSkin.swf']
    t.define

    assert_equal('-library-path+=bar -output=bin/SomeProjectSkin.swf -source-path+=src -source-path+=foo -source-path+=assets src/SomeProjectSkin.css', t.to_shell)
  end
  
  def test_stylesheet_prerequisites
    task :task1
    task :task2
    
    stylesheet :style => [:task1, :task2]
    t = Rake::application[:style]
    assert_equal(3, t.prerequisites.size)
  end

  def test_deploy_prerequisites
    task :task1
    task :task2
    
    deploy :deploy => [:task1, :task2]
    t = Rake::application[:deploy]
    assert_equal(3, t.prerequisites.size)
  end
  
  def test_library_task_from_model
    m = create_model
    m.libraries << :corelib
    
    deploy :deploy
    t = Rake::application[:deploy]
    #t.define
    
    assert Rake::application[:corelib]
  end
  
  def test_doc_helper
    create_model
    
    deploy :deploy
    document :doc

    t = Rake::application['doc/index.html']
    result = "-doc-sources+=src -doc-sources+=foo -doc-sources+=assets -library-path+=bar -output=doc"
    assert_equal(result, t.to_shell[0...result.size])
  end
  
  def test_flex_builder_helper
    create_model
    
    flex_builder :eclipse
    
    expected_project = File.open('.project', 'r').read
    expected_action_script_properties = File.open('.actionScriptProperties', 'r').read
    
    t = Rake::application['.project']
    assert_equal(expected_project, t.to_xml)
    
    t = Rake::application['.actionScriptProperties']
    assert_equal(expected_action_script_properties, t.to_xml)
  end

#  def test_swc_helper
#    create_model
#  end
end
