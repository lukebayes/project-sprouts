require File.dirname(__FILE__) + '/test_helper'

class RemoteFileTargetTest <  Test::Unit::TestCase
  include SproutTestCase

  def setup
    @fixtures_path       = File.join(fixtures, 'remote_file_target')
    
    @fixture_path        = File.join(@fixtures_path, 'macosx')
    @archive_folder_path = File.join(@fixtures_path, 'archive')
    @install_path        = File.join(@fixtures_path)

    @archive_path        = File.join('swfmill-0.2.12-macosx', 'swfmill')
    @file_name           = 'swfmill-0.2.12-macosx.tar.gz'
    @download_path       = File.join(@install_path, @file_name)

    @flashplayer_dir     = File.join(@fixtures_path, 'flashplayer')
    @flashplayer_gz      = File.join(@fixtures_path, 'flash_player_9_linux_dev.tar.gz')
    @flashplayer_binary  = File.join(@flashplayer_dir, 'archive', 'flash_player_9_linux_dev', 'standalone', 'debugger', 'flashplayer')
    
    @asunit_url          = 'http://github.com/lukebayes/asunit/zipball/4.0.0'
    @asunit_file_name    = '4.0.0'
    @asunit_md5          = 'dca47aa2334a3f66efd2912c208a8ef4'
    @asunit_dir          = File.join(@fixtures_path, 'asunit')
    @asunit_zip          = File.join(@asunit_dir, @asunit_file_name)
    @asunit_src          = File.join(@asunit_dir, 'archive', 'lukebayes-asunit-50da476d20fa87b71f71ed01b23cd3c4030b26c6', 'as3', 'src', 'asunit', 'framework', 'TestCase.as')

    ENV['SPROUT_TARGET_HOME'] = @fixtures_path

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
    remove_file @asunit_dir
    ENV['SPROUT_TARGET_HOME'] = nil
  end

  # BEGIN TEST FILE NAME VARIANTS:
  def test_file_name_zip
    target = Sprout::RemoteFileTarget.new
    assert_equal('foo.zip', target.file_name('http://www.foo.com/foo.zip'))
  end
  
  def test_file_name_tgz
    target = Sprout::RemoteFileTarget.new
    assert_equal('foo.tar.gz', target.file_name('http://www.foo.com/foo.tar.gz'))
  end
    
  def test_file_name_trailing_slash
    target = Sprout::RemoteFileTarget.new
    target.archive_type = 'zip'
    assert_equal('foo.zip', target.file_name('http://www.foo.com/foo/'))
  end
  
  def test_file_name_no_extension
    target = Sprout::RemoteFileTarget.new
    target.archive_type = 'zip'
    assert_equal('foo.zip', target.file_name('http://www.foo.com/foo'))
  end

  def test_file_name_get_params_and_no_extension_and_defined_archive_type
    target = Sprout::RemoteFileTarget.new
    target.archive_type = 'zip'
    assert_equal('foo.zip', target.file_name('http://www.foo.com/foo?bar=1234'))
  end
  
  def test_file_name_get_params_and_extension_type
    target = Sprout::RemoteFileTarget.new
    assert_equal('foo.tar.gz', target.file_name('http://www.foo.com/foo.tar.gz?bar=1234'))
  end

  def test_file_name_no_archive_type_or_extension
    target = Sprout::RemoteFileTarget.new
    assert_equal('foo', target.file_name('http://www.foo.com/foo'))
  end
  
  # END TEST FILE NAME VARIANTS:
  
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
  
  def test_simple_file_name
    assert_equal(@file_name, @target.file_name)
  end
  
  def test_rails_file_name
    assert_equal(@file_name, @target.file_name)
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

  # From asunit3 library gem_wrap:
  # platform: universal
  # archive_type: zip
  # url: http://github.com/lukebayes/asunit/zipball/4.0.0
  # md5: dca47aa2334a3f66efd2912c208a8ef4
  # archive_path: 'as3/src'  
  
  # def test_redirect_zip
  #   file_target = Sprout::RemoteFileTarget.new
  #   file_target.url = 'http://github.com/lukebayes/asunit/zipball/4.0.0'
  #   file_target.install_path = @asunit_dir
  #   file_target.downloaded_path = @asunit_zip
  #   file_target.md5 = 'dca47aa2334a3f66efd2912c208a8ef4'
  #   file_target.archive_path = 'lukebayes-asunit-50da476d20fa87b71f71ed01b23cd3c4030b26c6/as3/src'
  #   file_target.filename = 'asunit3.zip'
  # 
  #   assert_equal('asunit3.zip', file_target.file_name)
  # 
  #   file_target.resolve(true)
  #   
  #   assert_file @asunit_src
  # end
  
  def test_environment_variable
    file_target = Sprout::RemoteFileTarget.new
    file_target.environment = 'SPROUT_TARGET_HOME'
    file_target.archive_path = 'macosx'
    file_target.resolve true
    
    assert_file file_target.installed_path + '/macosx'
  end
  
  # def test_environment_variable_fallback_to_download
  #   ENV['SPROUT_TARGET_HOME'] = nil
  #   file_target = Sprout::RemoteFileTarget.new
  #   file_target.environment = 'SPROUT_TARGET_HOME' # fails
  #   file_target.url = 'http://github.com/lukebayes/asunit/zipball/4.0.0'
  #   file_target.install_path = @asunit_dir
  #   file_target.downloaded_path = @asunit_zip
  #   file_target.md5 = 'dca47aa2334a3f66efd2912c208a8ef4'
  #   file_target.archive_path = 'lukebayes-asunit-50da476d20fa87b71f71ed01b23cd3c4030b26c6/as3/src'
  #   file_target.filename = 'asunit3.zip'
  #   
  #   file_target.resolve true
  #   assert_file file_target.installed_path
  #   assert file_target.installed_path != ENV['SPROUT_TARGET_HOME']
  # end

end

module Sprout
  class RemoteFileTarget
    attr_writer :downloaded_path
  end
end
