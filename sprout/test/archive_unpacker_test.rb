require File.dirname(__FILE__) + '/test_helper'

class ArchiveUnpackerTest <  Test::Unit::TestCase
  include SproutTestCase

  def setup
    @fixture = File.join(fixtures, 'remote_file_target')

    @zip_fixture = File.join(fixtures, 'builder', 'mtasc-1.13-osx.zip')
    @zip_target = File.join(@fixture, 'mtasc')
    @zip_binary = File.join(@zip_target, 'mtasc-1.13-osx', 'mtasc')
    
    @tgz_fixture = File.join(fixtures, 'builder', 'swfmill-0.2.12-macosx.tar.gz')
    @tgz_target = File.join(@fixture, 'swfmill')
    @tgz_binary = File.join(@tgz_target, 'swfmill-0.2.12-macosx', 'swfmill')
    
    @unpacker = Sprout::ArchiveUnpacker.new
  end
  
  def teardown
    super
    remove_file @zip_target
    remove_file @tgz_target
  end
  
  def test_unpack_zip
    @unpacker.unpack_zip(@zip_fixture, @zip_target)
    assert_file @zip_binary
  end
  
  def test_unpack_tgz
    @unpacker.unpack_targz(@tgz_fixture, @tgz_target)
    assert_file @tgz_binary
  end
  
end