require 'test_helper'

require 'generators/<%= input.snake_case %>_generator'

class <%= input.camel_case %>GeneratorTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "A new <%= input.camel_case %> generator" do

    setup do
      # Create a temporary directory the generator can 
      # add files to:
      @temp             = File.join(fixtures, 'generators', 'tmp')
      FileUtils.mkdir_p @temp

      # Instantiate the generator:
      @generator        = Sprout::<%= input.camel_case %>Generator.new

      # Tell the generator to use the new temp path:
      @generator.path   = @temp

      # Hide generator output from terminal:
      # (uncomment to see output)
      @generator.logger = StringIO.new
    end

    teardown do
      # Remove the temp directory after each test method:
      remove_file @temp
    end

    # Run all test methods with:
    #
    #   ruby -I test/unit test/unit/<%= input.snake_case %>_generator_test.rb
    #
    # Run just this test method with:
    #
    #   ruby -I test/unit test/unit/<%= input.snake_case %>_generator_test.rb -n '/generate a new/'
    #
    should "generate a new <%= input.camel_case %>" do
      # provide example input:
      @generator.input = "<%= input.camel_case %>"
      @generator.execute

      input_dir = File.join @temp, "<%= input.snake_case %>"
      assert_directory input_dir

      input_file = File.join input_dir, "<%= input.camel_case %><%= extension %>"
      # Custom Sprout::TestHelper assertion, optional block
      # yields the file content as a String
      assert_file input_file do |content|
        # Custom Sprout::TestHelper assertion, update the Regex
        # with your expectation.
        assert_matches /Your content to assert here/, content
      end
    end

  end
end
