require 'test_helper'

class LibraryTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new archive library" do
    setup do
      @path = File.join fixtures, 'library', 'archive'
      @archive = File.join @path, 'Archive.swc'
      create_and_register_library :fake_archive_lib, :swc, @archive
    end

    should "be able to load registered libraries" do
      lib = Sprout::Library.load :swc, :fake_archive_lib
      assert_not_nil lib
    end
  end

  context "a new precompiled library" do
    setup do
      fixture  = File.join fixtures, 'library'
      @lib_dir = File.join fixture, 'project_lib'
      sources  = File.join fixture, 'sources'
      @src     = File.join sources, 'src', 'Source.as'

      Sprout::Library.any_instance.stubs(:project_path).returns @lib_dir
      create_and_register_library :fake_swc_lib, :swc, @src
    end

    should "create rake file tasks for single files" do
      Sprout::Library.define_task :swc, :fake_swc_lib
    end
  end

  context "a new source library" do
    setup do
      fixture  = File.join fixtures, 'library'
      @lib_dir = File.join fixture, 'project_lib'
      sources  = File.join fixture, 'sources'
      @lib_a   = File.join sources, 'lib', 'a'
      @lib_b   = File.join sources, 'lib', 'b'
      @src     = File.join sources, 'src'
      Sprout::Library.any_instance.stubs(:project_path).returns @lib_dir
      create_and_register_library :fake_source_lib, :src, [@src, @lib_a, @lib_b]
    end

    teardown do
      remove_file @lib_dir
    end

    should "be able to load registered libraries" do
      lib = Sprout::Library.load :src, :fake_source_lib
      assert_not_nil lib
      paths = lib.path.dup
      assert_equal @src, paths.shift
      assert_equal @lib_a, paths.shift
      assert_equal @lib_b, paths.shift
    end

    should "create rake file tasks for directories" do
      Sprout::Library.define_task :src, :fake_source_lib
      Rake::application[:resolve_sprout_libraries].invoke

      library_dir = File.join(@lib_dir, 'fake_source_lib')
      assert_file library_dir
      assert_file File.join(library_dir, 'Source.as')
      assert_file File.join(library_dir, 'a')
      assert_file File.join(library_dir, 'b')
    end

    should "create rake tasks for libraries" do
      library :fake_source_lib
      assert_not_nil Rake.application[:fake_source_lib]
    end
  end

  private

  def create_and_register_library pkg_name, name, path, pkg_version=nil
    lib             = Sprout::Library.new
    lib.name        = name
    lib.path        = path
    lib.pkg_name    = pkg_name unless pkg_name.nil?
    lib.pkg_version = pkg_version unless pkg_version.nil?
    Sprout::Library.register lib
  end
end

