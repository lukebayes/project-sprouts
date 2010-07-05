require File.join(File.dirname(__FILE__), "test_helper")

require 'generators/<%= input.snake_case %>_generator'

class <%= input.camel_case %>GeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "A new <%= input.camel_case %> generator" do

    setup do
      @temp             = File.join(fixtures, 'generators', 'tmp')
      FileUtils.mkdir_p @temp
      @generator        = Sprout::<%= input.camel_case %>Generator.new
      @generator.path   = @temp
      @generator.logger = StringIO.new
    end

    teardown do
      remove_file @temp
    end

    should "generate a new <%= input.camel_case %>" do
      @generator.input = "<%= input.camel_case %>"
      @generator.execute

      input_dir = File.join(@temp, "<%= input.snake_case %>")
      assert_directory input_dir

      input_file = File.join(input_dir, "<%= input.camel_case %><%= extension %>")
      assert_file input_file do |content|
        assert_matches /Your content to assert here/, content
      end
    end

  end
end
