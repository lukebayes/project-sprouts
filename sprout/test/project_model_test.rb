require File.dirname(__FILE__) + '/test_helper'

class ProjectModelTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @model = Sprout::ProjectModel.instance
  end
  
  def teardown
    @model = nil
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

end
