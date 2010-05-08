require File.join(File.dirname(__FILE__), "generator_test_helper.rb")

class ToolGeneratorTest < Test::Unit::TestCase
  include Sprout::GeneratorTestHelper

  context "running the tool generator" do

    ['someproject'].each do |input|
      context "with #{input} app root" do

        setup do
          @app_root = File.join(tmp_root, input)
        end

        should "use #{input}" do
          run_generator('tool', [app_root], app_sources)

          ['lib', 'src', 'script', 'test', 'bin'].each do |dir|
            assert_directory_exists dir
          end

          assert_generated_file 'rakefile.rb'
          assert_generated_file 'Gemfile'
          assert_generated_file "#{input}.gemspec"
        end
      end
    end

  end
end

