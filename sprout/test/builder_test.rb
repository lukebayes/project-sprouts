require File.dirname(__FILE__) + '/test_helper'

class BuilderTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @fixture = File.join(fixtures, 'builder')
    @auto_spec = File.join(@fixture, 'auto_install.yaml')
    @manual_spec = File.join(@fixture, 'manual_install.yaml')
  end
  
  def teardown
    path = File.join(@fixture, 'archive')
    remove_file(path)
  end
  
  def test_build
    Sprout::Builder.build(@auto_spec, @fixture)
    assert_file(File.join(@fixture, 'mtasc-1.13-osx.zip'))
  end
  
  # Ensure we support platform-specific self-install binaries, like swfmill on Linux
  def test_build_no_install
    result = Sprout::Builder.build(@manual_spec, @fixture)
    assert_equal('swfmill', result.executable)
  end
  
end