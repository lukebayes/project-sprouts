require File.dirname(__FILE__) + '/test_helper'

class GeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new application generator" do

    setup do
      @fixture          = File.join fixtures, 'generators', 'fake'
      @templates        = File.join fixtures, 'generators', 'templates'
      @string_io        = StringIO.new
      @generator        = configure_generator FakeGenerator.new

      FileUtils.mkdir_p @fixture
    end

    teardown do
      remove_file @fixture
    end

    should "register with the Sprout gem" do
      generator = Sprout.load_generator :application, 'fake', '>= 1.0.pre'
      assert_not_nil generator
    end

    context "that is asked to execute/create" do
      should "default path to pwd" do
        generator = FakeGenerator.new
        assert_equal Dir.pwd, generator.path
      end

      should "create outer directory and file" do
        @generator.name = 'some_project'
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

      should "copy templates from the first found template path" do
        @generator.name = 'some_project'
        @generator.band_name = 'R.E.M.'
        @generator.execute
        assert_file File.join(@fixture, 'some_project', 'SomeFile') do |content|
          assert_matches /got my Orange Crush - R.E.M./, content
        end
      end

      should "use concrete template when provided" do
        @generator.name = 'some_project'
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
        @generator.name = 'some_project'
        @string_io.expects(:puts).with('Created directory: ./some_project')
        @string_io.expects(:puts).with('Created file:      ./some_project/SomeFile')
        @string_io.expects(:puts).with('Created file:      ./some_project/SomeOtherFile')
        @string_io.expects(:puts).with('Created directory: ./some_project/src')
        @string_io.expects(:puts).with('Created file:      ./some_project/src/SomeProject.as')
        @generator.execute
      end

      should "not notify if quiet is true" do
        @generator.name = 'some_project'
        @generator.quiet = true
        @string_io.expects(:puts).never
        @generator.execute
      end

      should "only have one param in class definition" do
        assert_equal 2, FakeGenerator.static_parameter_collection.size
      end

      should "not update superclass parameter collection" do
        assert_equal 5, Sprout::Generator::Base.static_parameter_collection.size
      end

      ##
      # TODO: Add ability to prompt the user if requested files already exist,
      # and force != true
    end

    context "that is asked to unexecute/delete" do
      
      setup do
        @generator.name = 'some_project'
        @generator.execute

        @project = File.join @fixture, 'some_project'
        @file = File.join @project, 'SomeFile'

        assert_file File.join(@fixture, 'some_project')
      end
      
      should "remove the expected files" do
        @generator.unexecute
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
    generator.name   = 'some_project'
    generator.logger = @string_io
    generator.path   = @fixture
    generator.templates << @templates
    generator
  end

  ##
  # This is a fake Generator that should 
  # exercise the inputs.
  class FakeGenerator < Sprout::Generator::Base

    ##
    # Some argument for the Fake Generator
    add_param :band_name, String, { :default => 'Styx' }

    ##
    # Source path
    add_param :src, String, { :default => 'src' }

    def class_name
      @class_name ||= name.camel_case
    end

    def manifest
      directory name do
        file 'SomeFile'
        file 'SomeOtherFile', 'OtherFileTemplate'
        directory src do
          file "#{class_name}.as", 'Main.as'
        end
      end
    end
  end

  ##
  # This is a broken generator that should fail
  # with a MissingTemplateError
  class MissingTemplateGenerator < Sprout::Generator::Base
    def manifest
      directory name do
        file 'FileWithNoTemplate'
      end
    end
  end

end




