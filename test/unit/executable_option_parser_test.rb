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
    
    should "always accept help option" do
      @exe.expects :puts
      assert_raises SystemExit do
        @exe.parse [ '--help' ]
      end
    end

    should "accept false boolean" do
      assert @exe.falsey, "Should be true by default"
      @exe.parse [@default_input, '--falsey=false']
      assert !@exe.falsey, "Should be false"
    end

    should "accept string" do
      @exe.parse [@default_input, '--string=abcd']
      assert_equal 'abcd', @exe.string
    end

    should "accept file" do
      @exe.parse [@default_input, '--file=lib/sprout.rb']
      assert_equal 'lib/sprout.rb', @exe.file
    end

    should "accept files" do
      @exe.parse [@default_input, '--files+=lib/sprout.rb', '--files+=lib/sprout/log.rb']
      assert_equal ['lib/sprout.rb', 'lib/sprout/log.rb'], @exe.files
    end

    should "accept files assignment" do
      @exe.parse [@default_input, '--files=lib/sprout.rb', '--files=lib/sprout/log.rb']
      assert_equal ['lib/sprout.rb', 'lib/sprout/log.rb'], @exe.files
    end

    should "configure required arguments" do
      @exe.parse [@default_input, @default_input]
      assert_equal 'lib/sprout.rb', @exe.input
    end

    # TODO: This test ensures that the commandline description
    # is pulled from the provided RDocs - but this turns out
    # to be more work than I'm prepared to take on at the moment.
    #
    #should "use rdoc to assign parameter documentation" do
      #skip "Not yet ready to integrate rdoc comments"
      #doc = "A boolean parameter that defaults to true, and must be explicitly set to false in order to turn it off."
      #assert_matches /#{doc}/, @exe.to_help
    #end

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
end

