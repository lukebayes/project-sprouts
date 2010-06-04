require File.dirname(__FILE__) + '/test_helper'

class LibraryTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new library" do

    should "be able to register" do
      lib = OpenStruct.new({ :name => :asunit4, :pkg_name => 'asunit4', :pkg_version => '4.0.pre' })
      Sprout::Library.register lib
    end
  end
end

