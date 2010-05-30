require File.dirname(__FILE__) + '/test_helper'

class GeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new application generator" do

    setup do
      @fixture = File.join fixtures, 'generators'
      @generator = FakeGenerator.new
    end

    should "create foo directory" do
      @generator.execute
    end
  end
end


class FakeGenerator
  include Sprout::Generator

  def manifest
    directory 'foo'
  end
end


