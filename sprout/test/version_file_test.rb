require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/git_test_case.rb'

class VersionFileTest < GitTestCase

  def setup
    super
    @version = setup_version_file
  end
  
  def teardown
    super
  end
  
  def test_version_loaded
    assert_equal('2.3.4', @version.to_s, 'Revision was loaded from disk')
  end
  
  def test_to_tag
    assert_equal('02.03.004', @version.to_tag, 'Zeros should be appended for git tags')
  end

  def test_major_version
    assert_equal(2, @version.major_version, 'Major version was loaded from disk')
  end
  
  def test_minor_version
    assert_equal(3, @version.minor_version, 'Minor version was loaded from disk')
  end
  
  def test_increment_revision
    @version.increment_revision
    assert_equal('2.3.5', @version.to_s, 'Revision was incremented')
    
    @version = Sprout::VersionFile.new(@version_file)
    assert_equal('2.3.5', @version.to_s, 'Incremented revision was written to disk')
  end
end
