require File.dirname(__FILE__) + '/test_helper'

class RemoteFileTargetTest <  Test::Unit::TestCase
  include SproutTestCase

  def setup
    @fixtures_path = File.join(fixtures, 'remote_file_target') 
    @fixture_path = File.join(@fixtures_path, 'macosx')
    @archive_folder_path = File.join(@fixtures_path, 'archive')
    @install_path = File.join(@fixtures_path)
    @archive_path = File.join('swfmill-0.2.12-macosx', 'swfmill')
    @download_path = File.join(@install_path, 'swfmill-0.2.12-macosx.tar.gz')
    @flashplayer_dir = File.join(@fixtures_path, 'flashplayer')
    @flashplayer_gz = File.join(@fixtures_path, 'flash_player_9_linux_dev.tar.gz')
    @flashplayer_binary = File.join(@flashplayer_dir, 'archive', 'flash_player_9_linux_dev', 'standalone', 'debugger', 'flashplayer')
    data = nil
    File.open(@fixture_path, 'r') do |f|
      data = f.read
    end
    @target = YAML.load(data)
    # RemoteFileTargets need an installation path to work properly
    @target.install_path = @install_path
    
    FileUtils.mkdir_p @flashplayer_dir
  end
  
  def teardown
    super
    remove_file @archive_folder_path
    remove_file @flashplayer_dir
  end
  
  def test_serialization
    assert(@target)
  end
  
  # RemoteFiles should be unpacked into:
  # target.install_path + target.archive_path
  def test_installed_path
    expected = File.join(@install_path, 'archive')
    assert_equal(expected, @target.installed_path)
  end
  
  def test_archive_path
    assert_equal(@archive_path, @target.archive_path)
  end
  
  def test_download_path
    assert_equal(@download_path, @target.downloaded_path)
    assert(File.exists?(@target.downloaded_path))
  end
  
  def test_executable
    assert_equal('swfmill', @target.executable)
  end
  
  def test_resolve
    @target.resolve
    assert("Archive should be expanded", File.exists?(@archive_folder_path))
  end
  
  def test_child_gzip
    file_target = Sprout::RemoteFileTarget.new
    file_target.url = 'http://download.macromedia.com/pub/flashplayer/updaters/9/flash_player_9_linux_dev.tar.gz'
    file_target.install_path = @flashplayer_dir
    file_target.downloaded_path = @flashplayer_gz
    file_target.archive_path = 'flash_player_9_linux_dev/standalone/debugger/flashplayer'
    file_target.resolve
    
    assert_file @flashplayer_binary
  end
end

module Sprout
  class RemoteFileTarget
    attr_writer :downloaded_path
  end
end
