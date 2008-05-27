require File.dirname(__FILE__) + '/test_helper'

class ProjectModelTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @model = Sprout::ProjectModel.instance
  end
  
  def teardown
    Sprout::ProjectModel.destroy
    @model = nil
    clear_tasks
  end
  
  def test_source_path
    assert @model.source_path.is_a?(Array)
  end
  
  def test_library_path
    assert @model.library_path.is_a?(Array)
  end
  
  def test_libraries
    assert @model.libraries.is_a?(Array)
  end
  
  def test_modules
    assert @model.modules.is_a?(Array)
  end
  
  def test_external_css
    assert @model.external_css.is_a?(Array)
  end
  
  def test_unknown_property
    @model.unknown_property = 'mary'
    assert_equal('mary', @model.unknown_property)
  end
  
  def test_instance
    m = Sprout::ProjectModel.instance
    assert m
  end
  
  def test_setup
    m = Sprout::ProjectModel.setup
    assert m
  end
  
  def test_setup_block
    m = Sprout::ProjectModel.setup do |b|
      b.test_dir = 'foo'
    end
    
    assert_equal('foo', m.test_dir)
  end
  
  def test_instance_block
    m = Sprout::ProjectModel.instance do |b|
      b.test_dir = 'foo'
    end
    
    assert_equal('foo', m.test_dir)
  end
  
  def test_helper
    a = project_model :model_a do |p|
      p.test_dir = 'foo'
    end
    
    b = project_model :model_b do |p|
      p.test_dir = 'bar'
    end

    assert_equal('foo', a.test_dir)
    assert_equal('bar', b.test_dir)
    assert_equal('bar', Sprout::ProjectModel.instance.test_dir)
  end
  
  def test_framework_dirs
    m = project_model :model do |p|
      p.name = 'MyProject'
      p.src_dir = 'source'
    end
    
    assert_equal('source/myproject/models', m.model_dir)
    assert_equal('source/myproject/controllers', m.controller_dir)
    assert_equal('source/myproject/views', m.view_dir)
  end

end
