require File.dirname(__FILE__) + '/test_helper'

class GeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new application generator" do

    setup do
      @fixture          = File.join fixtures, 'generators', 'fake'
      @templates        = File.join fixtures, 'generators', 'templates'
      @string_io        = StringIO.new
      @generator        = configure_generator FakeGenerator.new
    end

    teardown do
      remove_file @fixture
    end

    should "default path to pwd" do
      generator = FakeGenerator.new
      assert_equal Dir.pwd, generator.path
    end

    should "create outer directory and file" do
      @generator.name = 'some_project'
      @generator.execute
      assert_directory File.join(@fixture, 'some_project')
      assert_file File.join(@fixture, 'some_project', 'SomeFile')
      assert_directory File.join(@fixture, 'some_project', 'script')
      assert_file File.join(@fixture, 'some_project', 'script', 'generate')
      assert_file File.join(@fixture, 'some_project', 'script', 'destroy')
    end

    should "copy templates from the first found template path" do
      @generator.name = 'some_project'
      @generator.execute
      assert_file File.join(@fixture, 'some_project', 'SomeFile') do |content|
        assert_matches /got my Orange Crush/, content
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
    end

    should "only have one param in class definition" do
      assert_equal 1, FakeGenerator.static_parameter_collection.size
    end

    should "not update superclass parameter collection" do
      assert_equal 4, Sprout::Generator.static_parameter_collection.size
    end

    should "fail if no template is found" do
      skip
    end

    should "prompt if requested file exists with different content" do
      skip
    end

    should "warn/skip if identical file exists" do
      skip
    end

    private

    def configure_generator generator
      generator.name   = 'some_project'
      generator.logger = @string_io
      generator.path   = @fixture
      generator.templates << @templates
      generator
    end
  end

  ##
  # This is a fake Generator that should 
  # exercise the inputs.
  class FakeGenerator < Sprout::Generator

    ##
    # Some argument for the Fake Generator
    add_param :some_other, String

    def manifest
      directory name do
        file 'SomeFile'
        file 'SomeOtherFile', 'OtherFileTemplate'
        create_script_dir
      end
    end
  end

  ##
  # This is a broken generator that should fail
  # with a MissingTemplateError
  class MissingTemplateGenerator < Sprout::Generator
    def manifest
      directory name do
        file 'FileWithNoTemplate'
      end
    end
  end
end




