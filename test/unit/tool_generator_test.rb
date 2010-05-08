require File.join(File.dirname(__FILE__), "generator_test_helper.rb")

class ToolGeneratorTest < Test::Unit::TestCase
  include Sprout::GeneratorTestHelper

  context "without options" do

    should "use default project name" do
      run_generator('tool', [APP_ROOT], app_sources)

      ['lib', 'src', 'script', 'test', 'bin'].each do |dir|
        assert_directory_exists dir
      end

      assert_generated_file 'rakefile.rb'
      assert_generated_file 'Gemfile'
    end
  end


end

