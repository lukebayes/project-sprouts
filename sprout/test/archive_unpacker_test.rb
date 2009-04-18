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
  
  def test_inferred_type_zip
    assert_equal :zip, @unpacker.inferred_archive_type('foo.zip')
  end

  def test_inferred_type_targz
    assert_equal :targz, @unpacker.inferred_archive_type('foo.tar.gz')
  end

  def test_inferred_type_gz
    assert_equal :gz, @unpacker.inferred_archive_type('foo.gz')
  end

  def test_inferred_type_exe
    assert_equal :exe, @unpacker.inferred_archive_type('foo.exe')
  end

  def test_inferred_type_rb
    assert_equal :rb, @unpacker.inferred_archive_type('foo.rb')
  end

  def test_inferred_type_swc
    assert_equal :swc, @unpacker.inferred_archive_type('foo.swc')
  end

  def test_inferred_type_nil
    assert_equal nil, @unpacker.inferred_archive_type('foo.zippy')
  end

  def test_unpack_zip
    @unpacker.unpack_archive(@zip_fixture, @zip_target)
    assert_file @zip_binary
  end
  
  def test_unpack_existing_archive
    test_unpack_zip
    @unpacker.unpack_archive(@zip_fixture, @zip_target, true)
  end
  
  def test_unpack_tgz
    @unpacker.unpack_archive(@tgz_fixture, @tgz_target)
    assert_file @tgz_binary
  end

end