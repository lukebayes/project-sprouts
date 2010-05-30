require File.dirname(__FILE__) + '/test_helper'

class GeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new application generator" do

    setup do
      @fixture = File.join fixtures, 'generators'
      @generator = FakeGenerator.new
    end

    should "create foo directory" do
      @generator.parse! ['some_project']
      @generator.execute
    end

    should "only have one param in class definition" do
      assert_equal 1, FakeGenerator.static_parameter_collection.size
    end

    should "not update superclass parameter collection" do
      assert_equal 1, Sprout::Generator.static_parameter_collection.size
    end
  end

  class FakeGenerator < Sprout::Generator

    add_param :some_other, String

    def manifest
      directory 'foo'
    end
  end
end




