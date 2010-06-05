require File.dirname(__FILE__) + '/test_helper'

class LibraryTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new archive library" do
    setup do
      @path = File.join fixtures, 'library', 'archive'
      @archive = File.join @path, 'Archive.swc'
      create_and_register_library :fake_archive_lib, @archive
    end

    should "be able to load registered libraries" do
      lib = Sprout::Library.load :fake_archive_lib
      assert_not_nil lib
    end
  end

  context "a new source library" do
    setup do
      sources = File.join fixtures, 'library', 'sources'
      @src    = File.join sources, 'src'
      @lib_a  = File.join sources, 'lib', 'a'
      @lib_b  = File.join sources, 'lib', 'b'
      create_and_register_library :fake_source_lib, [@src, @lib_a, @lib_b]
    end

    should "be able to load registered libraries" do
      lib = Sprout::Library.load :fake_source_lib
      assert_not_nil lib
      paths = lib.path.dup
      assert_equal @src, paths.shift
      assert_equal @lib_a, paths.shift
      assert_equal @lib_b, paths.shift
    end
  end

  private

  def create_and_register_library name, path, pkg_name=nil, pkg_version=nil
    lib             = OpenStruct.new
    lib.name        = name
    lib.path        = path
    lib.pkg_name    = pkg_name unless pkg_name.nil?
    lib.pkg_version = pkg_version unless pkg_version.nil?

    Sprout::Library.register lib
  end
end

