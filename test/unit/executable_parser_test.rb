require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/fake_parser_executable'

class ExecutableParserTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new parser" do
    setup do
      @exe  = FakeParserExecutable.new
    end

    context "with argv args" do

      should "explode on unknown or unexpected arguments" do
        assert_raises OptionParser::InvalidOption do
          @exe.parse ['--unknown-param']
        end
      end

      should "accept boolean" do
        @exe.parse ['--boolean-param=true']
        assert @exe.boolean_param, "Should be true"
      end

      should "accept string" do
        @exe.parse ['--string-param=abcd']
        assert_equal 'abcd', @exe.string_param
      end

      should "accept file" do
        @exe.parse ['--file-param=lib/sprout.rb']
        assert_equal 'lib/sprout.rb', @exe.file_param
      end

      should "accept files" do
        @exe.parse ['--files-param+=lib/sprout.rb', '--files-param+=lib/sprout/log.rb']
        assert_equal ['lib/sprout.rb', 'lib/sprout/log.rb'], @exe.files_param
      end

      should "configure required arguments" do
        @exe.parse ['--input=lib/sprout.rb']
        assert_equal 'lib/sprout.rb', @exe.input
      end

      should "fail without required param" do
        @exe.parse []
        assert_equal nil, @exe.input
      end

    end
  end
end


=begin
      should "parse the values with equals delimiter" do
        result = @exe.parse ['--source-path=lib/']
        assert_equal 1, result.size

        name_value = result.first
        assert_equal :source_path, name_value.name
        assert_equal 'lib/', name_value.value
      end

      should "parse values with space delimiter" do
        result = @exe.parse ['--source-path lib/']
        assert_equal 1, result.size

        name_value = result.first
        assert_equal :source_path, name_value.name
        assert_equal 'lib/', name_value.value
      end
=end

