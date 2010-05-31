require File.dirname(__FILE__) + '/test_helper'

class GeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new application generator" do

    setup do
      @fixture          = File.join fixtures, 'generators'
      @string_io        = StringIO.new
      @generator        = FakeGenerator.new
      @generator.logger = @string_io
      @generator.path   = @fixture
    end

    teardown do
      remove_file @fixture
    end

    should "default path to pwd" do
      generator = FakeGenerator.new
      assert_equal Dir.pwd, generator.path
    end

    should "create outer directory and file" do
      @generator.parse! ['some_project']
      @generator.execute
      assert_directory File.join(@fixture, 'some_project')
      assert_file File.join(@fixture, 'some_project', 'Gemfile')
      assert_directory File.join(@fixture, 'some_project', 'script')
      assert_directory File.join(@fixture, 'some_project', 'script', 'generate')
      assert_directory File.join(@fixture, 'some_project', 'script', 'destroy')
    end

    should "warn if identical file exists" do
      skip
    end

    should "prompt if requested file exists" do
      skip
    end

    should "only have one param in class definition" do
      assert_equal 1, FakeGenerator.static_parameter_collection.size
    end

    should "not update superclass parameter collection" do
      assert_equal 4, Sprout::Generator.static_parameter_collection.size
    end
  end

  class FakeGenerator < Sprout::Generator

    ##
    # Some argument for the Fake Generator
    add_param :some_other, String

    def manifest
      directory name do
        file 'Gemfile'
        create_script_dir
      end
    end

  end
end




