require File.dirname(__FILE__) + '/test_helper'

class GeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new application generator" do

    setup do
      @fixture = File.join fixtures, 'generators'
      @generator = Sprout::Generator.new
    end

    should "create foo directory" do
      @generator.parse! ['some_project']
      @generator.execute
    end
  end
end


class FakeGenerator < Sprout::Generator

  def manifest
    directory 'foo'
  end

end


