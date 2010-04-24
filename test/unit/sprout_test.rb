require File.dirname(__FILE__) + '/test_helper'

class SproutTest < Test::Unit::TestCase

  context "usage error" do
    should "be instantiable" do
      Sprout::Errors::UsageError.new
    end
  end

  context "standard error" do
    should "be instantiable" do
      Sprout::Errors::SproutError.new
    end
  end

  context "base" do
    should "be instantiable" do
      Sprout::Base.new
    end
  end

end

