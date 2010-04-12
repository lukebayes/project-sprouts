require File.dirname(__FILE__) + '/test_helper'

class PlatformTest < Test::Unit::TestCase
  include SproutTestCase

  context "platform" do

    setup do
      @platform = StubPlatform.new
    end

    ['cygwin', 'mingw', 'bccwin'].each do |variant|
      context variant do
        should "should know if they're windows nix" do
          @platform.stubs(:ruby_platform).returns variant
          assert @platform.windows?, "Windows?"
          assert @platform.windows_nix?, "Windows Nix?"
          assert !@platform.mac?, "Mac?"
          assert !@platform.unix?, "Unix?"
          assert !@platform.linux?, "Linux?"
        end
      end
    end

    ['mswin', 'wince', 'emx'].each do |variant|
      context variant do
        should "know if they're windows" do
          @platform.stubs(:ruby_platform).returns variant
          assert @platform.windows?, "Windows?"
          assert !@platform.mac?, "Mac?"
          assert !@platform.unix?, "Unix?"
          assert !@platform.windows_nix?, "Windows Nix?"
          assert !@platform.linux?, "Linux?"
        end
      end
    end

    ['solaris', 'redhat', 'ubuntu'].each do |variant|
      context variant do
        should "know if they're unix" do
          @platform.stubs(:ruby_platform).returns variant
          assert @platform.unix?, "Unix?"
          assert @platform.linux?, "Linux?"
          assert !@platform.windows?, "Windows?"
          assert !@platform.mac?, "Mac?"
          assert !@platform.windows_nix?, "Windows Nix?"
        end
      end
    end

    should "know if they're mac" do
      @platform.stubs(:ruby_platform).returns "darwin"
      assert @platform.mac?, "Mac?"
      assert @platform.unix?, "Unix?"
      assert !@platform.windows?, "Windows?"
      assert !@platform.windows_nix?, "Windows Nix?"
      assert !@platform.linux?, "Linux?"
    end

  end
end

class StubPlatform
  include Sprout::Platform
end
