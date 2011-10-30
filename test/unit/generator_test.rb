require 'test_helper'

class GeneratorTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "The Sprout::Generator" do

    should "identify a default set of search paths" do
      File.stubs(:directory?).returns true

      ENV['SPROUT_GENERATORS'] = Dir.pwd
      paths = Sprout::Generator.search_paths
      assert_equal File.join('config', 'generators'), paths.shift
      assert_equal File.join('vendor', 'generators'), paths.shift
      assert_equal Sprout.generator_cache, paths.shift
      assert_equal Dir.pwd, paths.shift
    end

    should "return empty search paths if no defaults are found" do
      File.stubs(:directory?).returns false
      paths = Sprout::Generator.search_paths
      assert_equal [], paths
    end
  end

  context "A new application generator" do

    setup do
      @fixture          = File.join fixtures, 'generators', 'fake'
      @templates        = File.join fixtures, 'generators', 'templates'
      @string_io        = StringIO.new
      @generator        = configure_generator FakeGenerator.new

      Sprout::Generator.register OtherFakeGenerator
      FileUtils.mkdir_p @fixture
    end

    teardown do
      remove_file @fixture
    end

    context "that is asked to execute/create" do
      should "default path to pwd" do
        generator = FakeGenerator.new
        assert_equal Dir.pwd, generator.path
      end

      should "create outer directory and file" do
        @generator.input = 'some_project'
        @generator.execute
        project = File.join(@fixture, 'some_project')
        assert_directory project
        assert_file File.join(project, 'SomeFile')
        assert_directory File.join(project, 'src')
        assert_file File.join(project, 'src', 'SomeProject.as') do |content|
          assert_matches /public class SomeProject/, content
          assert_matches /public function SomeProject/, content
        end
      end

      should "show template paths and nothing else" do
        @generator.parse! ['--show-template-paths']
        output = @generator.execute

        assert_equal 7, output.split("\n").size
      end

      should "not clobber existing files" do
        dir = File.join(@fixture, 'some_project', 'src')
        FileUtils.mkdir_p dir
        File.open File.join(dir, 'SomeProject.as'), 'w+' do |f|
          f.write "Hello World"
        end
        @generator.input = 'some_project'
        @generator.execute
        assert_matches /Hello World/, File.read(File.join(dir, 'SomeProject.as'))
      end

      should "clobber existing files if --force" do
        dir = File.join(@fixture, 'some_project', 'src')
        FileUtils.mkdir_p dir
        File.open File.join(dir, 'SomeProject.as'), 'w+' do |f|
          f.write "Hello World"
        end
        @generator.input = 'some_project'
        @generator.force = true
        @generator.execute
        assert_matches /public function SomeProject/, File.read(File.join(dir, 'SomeProject.as'))
      end

      should "call another generator" do
        @generator.external = true
        @generator.execute
        assert_file File.join(@fixture, 'some_project', 'SomeOtherOtherFile') do |content|
          assert_matches /We are agents of the free?/, content
        end
      end

      should "copy templates from the first found template path" do
        @generator.input = 'some_project'
        @generator.band_name = 'R.E.M.'
        @generator.execute
        assert_file File.join(@fixture, 'some_project', 'SomeFile') do |content|
          assert_matches /got my Orange Crush - R.E.M./, content
        end
      end

      should "respect updates from subclasses" do
        @generator = configure_generator SubclassedGenerator.new
        @generator.input = 'some_project'
        @generator.force = true
        @generator.execute
        assert_file File.join(@fixture, 'some_project', 'SomeFile') do |content|
          assert_matches /Living Jest enough for the City and SomeProject/, content
        end
      end

      should "use concrete template when provided" do
        @generator.input = 'some_project'
        @generator.execute
        assert_file File.join(@fixture, 'some_project', 'SomeOtherFile') do |content|
          assert_matches /I've had my fun/, content
        end
      end

      should "raise missing template error if expected template is not found" do
        @generator = configure_generator MissingTemplateGenerator.new
        assert_raises Sprout::Errors::MissingTemplateError do
          @generator.execute
        end

        assert !File.exists?(File.join(@fixture, 'some_project')), "Shouldn't leave half-generated files around"
      end

      should "notify user of all files created" do
        @generator.input = 'some_project'
        @string_io.expects(:puts).with('Skipped directory: .')
        @string_io.expects(:puts).with('Created directory: ./some_project')
        @string_io.expects(:puts).with('Created file:      ./some_project/SomeFile')
        @string_io.expects(:puts).with('Created file:      ./some_project/SomeOtherFile')
        @string_io.expects(:puts).with('Created directory: ./some_project/src')
        @string_io.expects(:puts).with('Created file:      ./some_project/src/SomeProject.as')
        @generator.execute
      end

      should "not notify if quiet is true" do
        @generator.input = 'some_project'
        @generator.quiet = true
        @string_io.expects(:puts).never
        @generator.execute
      end

      should "only have one param in class definition" do
        assert_equal 3, FakeGenerator.static_parameter_collection.size
        assert_equal 2, FakeGenerator.static_default_value_collection.size
      end

      should "not update superclass parameter collection" do
        assert_equal 7, Sprout::Generator::Base.static_parameter_collection.size
        assert_equal 1, Sprout::Generator::Base.static_default_value_collection.size
      end

      ##
      # TODO: Add ability to prompt the user if requested files already exist,
      # and force != true
    end

    context "that is asked to unexecute/delete" do

      setup do
        @generator.input = 'some_project'
        @generator.execute

        @project = File.join @fixture, 'some_project'
        @file = File.join @project, 'SomeFile'

        assert_file File.join(@fixture, 'some_project')
      end

      should "remove the expected files" do
        @generator.unexecute
        assert !File.exists?(@project), "Project should be deleted"
      end

      should "remove the expected files if destroy == true" do
        @generator.destroy = true
        @generator.execute
        assert !File.exists?(@project), "Project should be deleted"
      end

      should "not remove files (or their parents) that have been edited" do
        # Edit the file:
        File.open @file, 'w+' do |f|
          f.write "New Content"
        end

        @generator.unexecute
        assert !File.exists?(File.join(@project, 'src')), "src dir should be removed"
        assert_file @file, "Edited files should not be removed"
      end

      should "remove edited files if force is true" do
        # Edit the file:
        File.open @file, 'w+' do |f|
          f.write "New Content"
        end

        @generator.force = true
        @generator.unexecute
        assert !File.exists?(@project), "Project dir should be removed"
      end

      should "not remove directories that have files in them" do
        @file = File.join(@project, 'SomeNewFile.as')
        File.open(@file, 'w+') do |f|
          f.write 'New Content'
        end

        @generator.unexecute
        assert_file @file, 'New file should not be removed'
      end
    end

  end

  private

  def configure_generator generator
    generator.input  = 'some_project'
    generator.logger = @string_io
    generator.path   = @fixture
    generator.templates << @templates
    generator
  end

  ##
  # This is a fake Generator that should
  # exercise the inputs.
  class FakeGenerator < Sprout::Generator::Base

    add_param :external, Boolean

    ##
    # Register this generator by input, type and version
    #register :application, :fake, '1.0.pre'

    ##
    # Some argument for the Fake Generator
    add_param :band_name, String, { :default => 'Styx' }

    ##
    # Source path
    add_param :src, String, { :default => 'src' }

    ##
    # The package (usually Gem) name
    set :pkg_name, 'generator_test'

    ##
    # The package version
    set :pkg_version, '1.0.pre'

    def class_name
      @class_name ||= input.camel_case
    end

    def manifest
      directory input do
        template 'SomeFile'
        template 'SomeOtherFile', 'OtherFileTemplate'
        generator :other_fake if external
        directory src do
          template "#{class_name}.as", 'Main.as'
        end
      end
    end
  end

  class OtherFakeGenerator < Sprout::Generator::Base
    add_param :band_name, String, { :default => 'Barf' }

    def manifest
      directory input do
        template 'SomeOtherOtherFile', 'OtherFileTemplate'
      end
    end
  end

  context "an unregistered generator" do

    setup do
      @generators = File.join fixtures, 'generators'
      @path       = File.join @generators, 'fake'
      @project    = File.join @path, 'SomeProject'
      $:.unshift @generators
    end

    teardown do
      $:.shift
      remove_file @path
    end

    should "fail to find unknown generator" do
      assert_raises Sprout::Errors::LoadError do
        generator = Sprout::Generator.load :demo, 'unknown_file', '>= 1.0.pre'
      end
    end

    should "be loadable if it's in the load path" do
      generator = Sprout::Generator.load :application, 'temp_generator', '>= 1.0.pre'
      assert_not_nil generator

      generator.logger = StringIO.new
      generator.path = @path
      generator.input = 'SomeProject'
      generator.execute
      assert_file @project, "Should have created project folder"
    end
  end

  context "a generator that is a subclass of another" do
    # Require the source files for this context
    require 'fixtures/generators/song_generator'
    require 'fixtures/generators/song_subclass/least_favorite'

    setup do
      @path = File.join(fixtures, 'generators', 'tmp')
      FileUtils.mkdir_p @path

      @song_generator = SongGenerator.new
      @song_generator.logger = StringIO.new
      @song_generator.path = @path

      @least_favorite = LeastFavorite.new
      @least_favorite.logger = StringIO.new
      @least_favorite.path = @path
    end

    teardown do
      remove_file @path
    end

    should "select templates from where it's defined - not it's superclass" do
      @song_generator.favorite = 'I Feel Better'
      @song_generator.execute
      assert_file File.join(@path, 'i_feel_better.txt') do |content|
        assert_matches /Your favorite song is 'I Feel Better'/, content
      end

      @least_favorite.favorite = 'I Feel Better'
      @least_favorite.execute
      assert_file File.join(@path, 'sucky', 'i_feel_better.txt') do |content|
        assert_matches /Your LEAST favorite song is 'I Feel Better'/, content
      end
    end

  end

  class SubclassedGenerator < FakeGenerator

    add_param :new_param, String, { :default => 'Other' }

    def manifest
      super
      directory input do
        template 'SomeFile', 'SomeSubclassFile'
      end
    end
  end

  ##
  # This is a broken generator that should fail
  # with a MissingTemplateError
  class MissingTemplateGenerator < Sprout::Generator::Base

    def manifest
      directory input do
        template 'FileWithNoTemplate'
      end
    end
  end

end




