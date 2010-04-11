require File.dirname(__FILE__) + '/test_helper'

puts "Loaded test case"

class SproutTest < Test::Unit::TestCase

  context "base" do

    should "be instantiable" do
      Sprout::Base.new
    end
  end

end

