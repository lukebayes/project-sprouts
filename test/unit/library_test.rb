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

  context "a new precompiled library" do
    setup do
      fixture  = File.join fixtures, 'library'
      @lib_dir = File.join fixture, 'project_lib'
      sources  = File.join fixture, 'sources'
      @src     = File.join sources, 'src', 'Source.as'
      Sprout::Library.project_path = @lib_dir
      create_and_register_library :fake_swc_lib, @src
    end

    should "create rake file tasks for single files" do
      Sprout::Library.define_task :fake_swc_lib
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
      Sprout::Library.project_path = @lib_dir
      create_and_register_library :fake_source_lib, [@src, @lib_a, @lib_b]
    end

    teardown do
      Sprout::Library.project_path = nil
      remove_file @lib_dir
    end

    should "be able to load registered libraries" do
      lib = Sprout::Library.load :fake_source_lib
      assert_not_nil lib
      paths = lib.path.dup
      assert_equal @src, paths.shift
      assert_equal @lib_a, paths.shift
      assert_equal @lib_b, paths.shift
    end

    should "create rake file tasks for directories" do
      Sprout::Library.define_task :fake_source_lib
      Rake::application[:resolve_sprout_libraries].invoke

      library_dir = File.join(@lib_dir, 'fake_source_lib')
      assert_file library_dir
      assert_file File.join(library_dir, 'Source.as')
      assert_file File.join(library_dir, 'a')
      assert_file File.join(library_dir, 'b')
    end

    should "load the library from the load_path" do
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

