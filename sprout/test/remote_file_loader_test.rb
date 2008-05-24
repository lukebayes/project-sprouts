require File.dirname(__FILE__) + '/test_helper'

class RemoteFileLoaderTest <  Test::Unit::TestCase
  include SproutTestCase

  def setup
    @fixture = File.join(fixtures, 'remote_file_target')
#    @zip_fixture = "/Users/lbayes/Library/Sprouts/cache/0.7/sprout-flex3sdk-tool-3.0.0/flex_sdk_3.zip"
    @zip_fixture = File.join(fixtures, 'builder', 'mtasc-1.13-osx.zip')
    @zip_target = File.join(@fixture, 'archive')
    
    @unpacked_zip = File.join(@zip_target, 'mtasc-1.13-osx')
    @binary_target = File.join(@unpacked_zip, 'mtasc')
    
    @download_path = File.join(@fixture, 'swfmill-0.2.12-macosx.tar.gz')
    @md5 = '9c708c0fc4977f774a70671e06420e52'
    
    @loader = Sprout::RemoteFileLoader.new
  end
  
  def teardown
    super
    remove_file @zip_target
  end
  
  def test_check_md5
    bytes = nil
    File.open(@download_path, 'r') do |f|
      bytes = f.read
    end
    
    assert("MD5 hash should match", @loader.response_is_valid?(bytes, @md5))
  end
  
  def test_unpack_zip
    @loader.unpack_zip(@zip_fixture, @zip_target)
    assert_file @binary_target
  end
  
end