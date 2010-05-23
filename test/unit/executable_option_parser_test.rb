require File.dirname(__FILE__) + '/test_helper'
require 'test/fixtures/examples/echo_inputs'

class ExecutableOptionParserTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new ruby executable" do
    
    setup do
      @exe = EchoInputs.new
      @exe.abort_on_failure = false
      @default_input = '--input=lib/sprout.rb'
    end

    should "fail without required args" do
      assert_raises Sprout::Errors::MissingArgumentError do
        @exe.parse []
      end
    end

    should "accept required args" do
      @exe.parse [ @default_input ]
      assert_equal 'lib/sprout.rb', @exe.input
    end

    should "accept boolean with hidden_value" do
      assert !@exe.truthy
      @exe.parse [ '--truthy', @default_input ]
      assert @exe.truthy
    end

    context "with an unknown option" do
      should "throw an exception" do
        assert_raises OptionParser::InvalidOption do
          @exe.parse [ '--unknown-param', @default_input ]
        end
      end

      should "abort and display help" do
        @exe.abort_on_failure = true
        @exe.expects :abort
        @exe.parse [ '--unknown-param', @default_input ]
      end
    end

  end

  context "a new parser" do
    setup do
      @exe  = FakeParserExecutable.new
      @exe.abort_on_failure = false
    end

    context "with argv args" do

      should "accept boolean" do
        @exe.parse ['--input=lib/sprout.rb', '--boolean-param=true']
        assert @exe.boolean_param, "Should be true"
      end

      should "accept string" do
        @exe.parse ['--input=lib/sprout.rb', '--string-param=abcd']
        assert_equal 'abcd', @exe.string_param
      end

      should "accept file" do
        @exe.parse ['--input=lib/sprout.rb', '--file-param=lib/sprout.rb']
        assert_equal 'lib/sprout.rb', @exe.file_param
      end

      should "accept files" do
        @exe.parse ['--input=lib/sprout.rb', '--files-param+=lib/sprout.rb', '--files-param+=lib/sprout/log.rb']
        assert_equal ['lib/sprout.rb', 'lib/sprout/log.rb'], @exe.files_param
      end

      should "configure required arguments" do
        @exe.parse ['--input=lib/sprout.rb', '--input=lib/sprout.rb']
        assert_equal 'lib/sprout.rb', @exe.input
      end

      should "fail without required param" do
        assert_raises Sprout::Errors::MissingArgumentError do
          @exe.parse []
        end
      end

      should "fail with incorreect param" do
        assert_raises Sprout::Errors::InvalidArgumentError do
          @exe.parse ['--input=lib/unknown_file.rb']
        end
      end

    end
  end
end

