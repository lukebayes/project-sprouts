require File.dirname(__FILE__) + '/test_helper'

class RemoteFileLoaderTest <  Test::Unit::TestCase
  include SproutTestCase

  def setup
    @fixture = File.join(fixtures, 'remote_file_target')

    @redirect_url = 'http://github.com/lukebayes/asunit/zipball/4.0.0'

    @download_path = File.join(@fixture, 'swfmill-0.2.12-macosx.tar.gz')
    @md5 = '9c708c0fc4977f774a70671e06420e52'
    
    @loader = Sprout::RemoteFileLoader.new
  end
  
  def teardown
    super
  end
  
  def test_check_md5
    bytes = nil
    File.open(@download_path, 'r') do |f|
      bytes = f.read
    end
    
    assert("MD5 hash should match", @loader.response_is_valid?(bytes, @md5))
  end
end