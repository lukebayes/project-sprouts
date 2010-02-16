require File.dirname(__FILE__) + '/test_helper'

class LibraryTaskTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def test_clean_simple_gem_name
    assert_equal 'sprout-foo-library', get_simple_stub(:foo).gem_name
  end
  
  def test_leave_gem_name_if_defined
    lib = get_simple_stub('foo')
    lib.gem_name = 'username-sprout-foo-library'
    assert_equal 'username-sprout-foo-library', lib.gem_name
  end
  
  def test_clean_name
    lib = get_simple_stub('foo')
    lib.gem_name = 'username-sprout-foo-library'
    assert_equal 'foo', lib.clean_name
  end
  
  def test_clean_name
    lib = get_simple_stub('foo')
    assert_equal 'foo', lib.clean_name
  end
  
  private
  
  def get_simple_stub(name)
    Sprout::LibraryTask.any_instance.stubs(:define).returns(nil)
    Sprout::LibraryTask.new(name, Rake.application)
  end
end
