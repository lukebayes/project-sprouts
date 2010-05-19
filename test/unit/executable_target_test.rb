require File.dirname(__FILE__) + '/test_helper'

class SproutTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new executable with version" do

    setup do
      @executable = Sprout::ExecutableTarget.new :pkg_version => '1.0.0'
    end

    should "fail for lesser versions" do
      assert !@executable.satisfies_requirement?('>= 1.0.1')
    end

    should "pass for the same version" do
      assert @executable.satisfies_requirement?('1.0.0')
    end
    
    should "pass for same or greater than version" do
      assert @executable.satisfies_requirement?('>= 1.0.0')
    end

    should "pass for greater than lesser version" do
      assert @executable.satisfies_requirement?('>= 0.0.9')
    end
  end

  context "a new executable with pkg_name" do

    setup do
      @executable = Sprout::ExecutableTarget.new :pkg_name => 'echomaker'
    end

    should "fail for non-match" do
      assert !@executable.includes_package_name?('echo')
    end

    should "pass when name is included" do
      assert @executable.includes_package_name?('echomaker')
    end

    should "pass when name is included in bigger file" do
      assert @executable.includes_package_name?('test/fixtures/echo/lib/echomaker')
    end

  end
end

