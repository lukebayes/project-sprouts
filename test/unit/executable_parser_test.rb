require File.dirname(__FILE__) + '/test_helper'

class ExecutableParserTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new parser" do
    setup do
      @parser = Sprout::Executable::Parser.new
    end

    context "with argv args" do

      should "parse the values with equals delimiter" do
        result = @parser.parse ['--source-path=lib/']
        assert_equal 1, result.size

        name_value = result.first
        assert_equal :source_path, name_value.name
        assert_equal 'lib/', name_value.value
      end

      should "parse values with space delimiter" do
        skip "This is where I left off on the naive option parser"

        result = @parser.parse ['--source-path lib/']
        assert_equal 1, result.size

        name_value = result.first
        assert_equal :source_path, name_value.name
        assert_equal 'lib/', name_value.value
      end
    end
  end

end

